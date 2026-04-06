# Queue Wrapper Example (Message Queue)

## Contents
- Problem: Direct queue SDK coupling issues
- Solution: Separated publisher and subscriber wrappers
- Publisher wrapper (infrastructure + domain layers)
- Subscriber wrapper (infrastructure + domain layers)
- Benefits of separation
- Pattern: In-memory queue for testing
- Key decisions on what to expose, hide, and keep in domain

## Problem

Direct queue SDK usage couples business logic to infrastructure:

```python
# AWS SQS scattered across services
import boto3

sqs = boto3.client('sqs')
queue_url = 'https://sqs.region.amazonaws.com/account/queue-name'

# Sending
sqs.send_message(
    QueueUrl=queue_url,
    MessageBody=json.dumps({'event': 'OrderCreated', 'order_id': 123}),
    MessageAttributes={
        'EventType': {'StringValue': 'OrderCreated', 'DataType': 'String'}
    }
)

# Receiving
response = sqs.receive_message(QueueUrl=queue_url, MaxNumberOfMessages=10)
for msg in response.get('Messages', []):
    body = json.loads(msg['Body'])
    # Process...
    sqs.delete_message(QueueUrl=queue_url, ReceiptHandle=msg['ReceiptHandle'])
```

Issues:
- Queue URLs hardcoded or scattered
- Message format inconsistent
- SQS-specific concepts (ReceiptHandle, MessageAttributes) everywhere
- Testing requires AWS mocks
- Cannot easily switch to RabbitMQ, Kafka, or in-memory queue

## Solution: Separated Publisher and Subscriber

### Publisher Wrapper

**Infrastructure layer**:

```python
class QueuePublisher:
    """Minimal wrapper for publishing messages to a queue."""

    def __init__(self, sqs_client, queue_url: str):
        self._sqs = sqs_client
        self._queue_url = queue_url

    def publish(self, message_type: str, payload: dict) -> None:
        """Publish a message to the queue."""
        self._sqs.send_message(
            QueueUrl=self._queue_url,
            MessageBody=json.dumps(payload),
            MessageAttributes={
                'MessageType': {
                    'StringValue': message_type,
                    'DataType': 'String'
                }
            }
        )
```

**Domain layer**:

```python
class OrderEventPublisher:
    """Publishes order-related domain events."""

    def __init__(self, publisher: QueuePublisher):
        self._publisher = publisher

    def order_created(self, order_id: int, customer_id: int, total: Decimal) -> None:
        """Publish order created event."""
        self._publisher.publish(
            message_type='OrderCreated',
            payload={
                'order_id': order_id,
                'customer_id': customer_id,
                'total': str(total),
                'created_at': datetime.utcnow().isoformat()
            }
        )

    def order_shipped(self, order_id: int, tracking_number: str) -> None:
        """Publish order shipped event."""
        self._publisher.publish(
            message_type='OrderShipped',
            payload={
                'order_id': order_id,
                'tracking_number': tracking_number,
                'shipped_at': datetime.utcnow().isoformat()
            }
        )
```

### Subscriber Wrapper

**Infrastructure layer**:

```python
from typing import Callable

class QueueSubscriber:
    """Minimal wrapper for consuming messages from a queue."""

    def __init__(self, sqs_client, queue_url: str):
        self._sqs = sqs_client
        self._queue_url = queue_url

    def poll(self, handler: Callable[[str, dict], None], batch_size: int = 10) -> None:
        """Poll for messages and invoke handler for each."""
        response = self._sqs.receive_message(
            QueueUrl=self._queue_url,
            MaxNumberOfMessages=batch_size,
            WaitTimeSeconds=20  # Long polling
        )

        for msg in response.get('Messages', []):
            message_type = msg.get('MessageAttributes', {}) \
                .get('MessageType', {}) \
                .get('StringValue', 'Unknown')
            payload = json.loads(msg['Body'])

            try:
                handler(message_type, payload)
                self._delete_message(msg['ReceiptHandle'])
            except Exception as e:
                # Log error, message stays in queue for retry
                print(f"Error processing message: {e}")

    def _delete_message(self, receipt_handle: str) -> None:
        """Remove processed message from queue."""
        self._sqs.delete_message(
            QueueUrl=self._queue_url,
            ReceiptHandle=receipt_handle
        )
```

**Domain layer**:

```python
class OrderEventSubscriber:
    """Subscribes to order-related domain events."""

    def __init__(
        self,
        subscriber: QueueSubscriber,
        order_service: OrderService,
        notification_service: NotificationService
    ):
        self._subscriber = subscriber
        self._order_service = order_service
        self._notification_service = notification_service

    def start(self) -> None:
        """Start consuming messages."""
        self._subscriber.poll(self._handle_message)

    def _handle_message(self, message_type: str, payload: dict) -> None:
        """Route message to appropriate handler."""
        handlers = {
            'OrderCreated': self._on_order_created,
            'OrderShipped': self._on_order_shipped,
        }

        handler = handlers.get(message_type)
        if handler:
            handler(payload)
        else:
            print(f"Unknown message type: {message_type}")

    def _on_order_created(self, payload: dict) -> None:
        """Handle order created event."""
        order_id = payload['order_id']
        customer_id = payload['customer_id']
        self._notification_service.send_order_confirmation(customer_id, order_id)

    def _on_order_shipped(self, payload: dict) -> None:
        """Handle order shipped event."""
        order_id = payload['order_id']
        tracking = payload['tracking_number']
        self._order_service.update_tracking(order_id, tracking)
```

## Benefits

**Separation of concerns**: Publisher doesn't know about subscriber, subscriber doesn't know about publisher.

**Domain-aligned**: Method names describe business events, not queue operations.

**Testability**: Mock QueuePublisher/QueueSubscriber, not SQS. Test event handlers independently.

**Queue-agnostic**: Swap SQS for RabbitMQ by reimplementing wrappers, domain layer unchanged.

**Error handling**: Wrapper handles infrastructure errors, domain handles business errors.

## Pattern: In-Memory Queue for Testing

```python
class InMemoryQueuePublisher:
    """Test double for queue publisher."""

    def __init__(self):
        self.published_messages = []

    def publish(self, message_type: str, payload: dict) -> None:
        self.published_messages.append((message_type, payload))


class InMemoryQueueSubscriber:
    """Test double for queue subscriber."""

    def __init__(self):
        self.messages = []

    def add_message(self, message_type: str, payload: dict) -> None:
        """Add message for testing."""
        self.messages.append((message_type, payload))

    def poll(self, handler: Callable[[str, dict], None], batch_size: int = 10) -> None:
        """Process all queued messages."""
        for message_type, payload in self.messages:
            handler(message_type, payload)
        self.messages.clear()
```

Use in tests:

```python
def test_order_created_sends_notification():
    # Arrange
    publisher = InMemoryQueuePublisher()
    order_publisher = OrderEventPublisher(publisher)

    # Act
    order_publisher.order_created(order_id=123, customer_id=456, total=Decimal('99.99'))

    # Assert
    assert len(publisher.published_messages) == 1
    msg_type, payload = publisher.published_messages[0]
    assert msg_type == 'OrderCreated'
    assert payload['order_id'] == 123
```

## Key Decisions

**What to expose**: `publish()` for sending, `poll()` for receiving. Not batch operations, DLQ handling, or visibility timeouts until needed.

**What to hide**: Queue URLs, receipt handles, message attributes format, AWS-specific concepts.

**What stays in domain**: Message types, payload schemas, routing logic, business error handling.

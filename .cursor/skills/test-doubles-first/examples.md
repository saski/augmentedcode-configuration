# Examples

## Python (pytest style)

### Fake (Python)

```python
class FakeOrderRepo:
    def __init__(self) -> None:
        self._store: dict[str, Order] = {}

    def add(self, order: Order) -> None:
        self._store[order.id] = order

    def get(self, order_id: str) -> Order | None:
        return self._store.get(order_id)
```

### Stub (Python)

```python
class StubPaymentGateway:
    def __init__(self, should_succeed: bool = True) -> None:
        self.should_succeed = should_succeed

    def charge(self, order_id: str, amount_cents: int) -> str:
        if not self.should_succeed:
            raise RuntimeError("payment failed")
        return f"pay_{order_id}"
```

### Spy (Python)

```python
class SpyEmailService:
    def __init__(self) -> None:
        self.sent: list[dict[str, str]] = []

    def send_receipt(self, to: str, order_id: str, payment_id: str) -> None:
        self.sent.append({"to": to, "order_id": order_id, "payment_id": payment_id})
```

### Mock (Python, contract-focused only)

```python
from unittest.mock import Mock

emails = Mock()
# ...
emails.send_receipt.assert_not_called()
```

## TypeScript (Jest style)

### Fake (TypeScript)

```ts
export class FakeOrderRepo {
  private store = new Map<string, Order>();

  add(order: Order): void {
    this.store.set(order.id, order);
  }

  get(orderId: string): Order | undefined {
    return this.store.get(orderId);
  }
}
```

### Stub (TypeScript)

```ts
export class StubPaymentGateway {
  constructor(private readonly shouldSucceed = true) {}

  charge(orderId: string, amountCents: number): string {
    if (!this.shouldSucceed) {
      throw new Error("payment failed");
    }
    return `pay_${orderId}`;
  }
}
```

### Spy (TypeScript)

```ts
export class SpyEmailService {
  public sent: Array<{ to: string; orderId: string; paymentId: string }> = [];

  sendReceipt(to: string, orderId: string, paymentId: string): void {
    this.sent.push({ to, orderId, paymentId });
  }
}
```

### Mock (TypeScript, contract-focused only)

```ts
const emails = { sendReceipt: jest.fn() };
// ...
expect(emails.sendReceipt).not.toHaveBeenCalled();
```

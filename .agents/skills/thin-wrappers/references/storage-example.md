# Storage Wrapper Example (S3/Object Storage)

## Contents
- Problem: Direct S3 SDK usage issues
- Solution: Two-layer domain-aligned storage wrapper
- Domain-specific storage examples
- Alternative: Single-layer for simple cases
- Testing pattern: In-memory storage
- Benefits of wrapper approach
- Key decisions on what to expose, hide, and keep in domain
- When to extend the wrapper

## Problem

Direct S3 SDK usage scatters storage details throughout the application:

```python
# AWS S3 boto3 scattered across services
import boto3

s3 = boto3.client('s3')
bucket_name = 'my-app-uploads'

# Uploading
s3.put_object(
    Bucket=bucket_name,
    Key=f'users/{user_id}/avatar.jpg',
    Body=file_content,
    ContentType='image/jpeg',
    Metadata={'uploaded_by': str(user_id)}
)

# Downloading
response = s3.get_object(Bucket=bucket_name, Key=f'users/{user_id}/avatar.jpg')
content = response['Body'].read()

# Generating URLs
url = s3.generate_presigned_url(
    'get_object',
    Params={'Bucket': bucket_name, 'Key': f'users/{user_id}/avatar.jpg'},
    ExpiresIn=3600
)
```

Issues:
- Bucket names and paths scattered
- S3-specific concepts (Keys, Buckets, presigned URLs) in business logic
- Path construction logic duplicated
- Content type management inconsistent
- Testing requires AWS mocks or MinIO
- Cannot switch to Azure Blob, GCS, or local filesystem easily

## Solution: Domain-Aligned Storage Wrapper

### Two-Layer Approach

**Infrastructure layer** - Thin wrapper:

```python
from dataclasses import dataclass

@dataclass
class StoredFile:
    """Result of file storage operation."""
    path: str
    size: int
    content_type: str


class ObjectStorage:
    """Minimal wrapper for object storage operations."""

    def __init__(self, s3_client, bucket_name: str):
        self._s3 = s3_client
        self._bucket = bucket_name

    def store(self, path: str, content: bytes, content_type: str) -> StoredFile:
        """Store file at path."""
        self._s3.put_object(
            Bucket=self._bucket,
            Key=path,
            Body=content,
            ContentType=content_type
        )
        return StoredFile(
            path=path,
            size=len(content),
            content_type=content_type
        )

    def retrieve(self, path: str) -> bytes:
        """Retrieve file content by path."""
        response = self._s3.get_object(Bucket=self._bucket, Key=path)
        return response['Body'].read()

    def exists(self, path: str) -> bool:
        """Check if file exists at path."""
        try:
            self._s3.head_object(Bucket=self._bucket, Key=path)
            return True
        except self._s3.exceptions.NoSuchKey:
            return False

    def delete(self, path: str) -> None:
        """Remove file at path."""
        self._s3.delete_object(Bucket=self._bucket, Key=path)

    def generate_access_url(self, path: str, expires_in_seconds: int) -> str:
        """Generate temporary access URL."""
        return self._s3.generate_presigned_url(
            'get_object',
            Params={'Bucket': self._bucket, 'Key': path},
            ExpiresIn=expires_in_seconds
        )
```

**Domain layer** - Business logic using wrapper:

```python
class UserAvatarStorage:
    """Manages storage of user avatar images."""

    ALLOWED_TYPES = {'image/jpeg', 'image/png', 'image/webp'}
    MAX_SIZE = 5 * 1024 * 1024  # 5MB
    URL_EXPIRY = 3600  # 1 hour

    def __init__(self, storage: ObjectStorage):
        self._storage = storage

    def store_avatar(self, user_id: int, content: bytes, content_type: str) -> str:
        """Store user avatar image."""
        self._validate_upload(content, content_type)

        path = self._avatar_path(user_id)
        stored = self._storage.store(path, content, content_type)

        return path

    def get_avatar_url(self, user_id: int) -> str | None:
        """Get temporary URL for user avatar."""
        path = self._avatar_path(user_id)

        if not self._storage.exists(path):
            return None

        return self._storage.generate_access_url(path, self.URL_EXPIRY)

    def delete_avatar(self, user_id: int) -> None:
        """Remove user avatar."""
        path = self._avatar_path(user_id)
        if self._storage.exists(path):
            self._storage.delete(path)

    def _avatar_path(self, user_id: int) -> str:
        """Construct storage path for avatar."""
        return f"users/{user_id}/avatar.jpg"

    def _validate_upload(self, content: bytes, content_type: str) -> None:
        """Validate upload constraints."""
        if content_type not in self.ALLOWED_TYPES:
            raise ValueError(f"Invalid content type: {content_type}")

        if len(content) > self.MAX_SIZE:
            raise ValueError(f"File too large: {len(content)} bytes")
```

### Domain-Specific Storage

For more complex domains, create specialized storage classes:

```python
class DocumentStorage:
    """Manages legal document storage with versioning."""

    def __init__(self, storage: ObjectStorage):
        self._storage = storage

    def store_document(
        self,
        document_id: str,
        version: int,
        content: bytes,
        format: str
    ) -> None:
        """Store document version."""
        path = f"documents/{document_id}/v{version}.{format}"
        self._storage.store(path, content, self._content_type(format))

    def retrieve_document(self, document_id: str, version: int, format: str) -> bytes:
        """Retrieve specific document version."""
        path = f"documents/{document_id}/v{version}.{format}"
        return self._storage.retrieve(path)

    def _content_type(self, format: str) -> str:
        """Map format to content type."""
        types = {
            'pdf': 'application/pdf',
            'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'txt': 'text/plain'
        }
        return types.get(format, 'application/octet-stream')
```

## Alternative: Single-Layer for Simple Cases

```python
class InvoiceStorage:
    """Stores invoices with built-in S3 wrapper."""

    def __init__(self, s3_client, bucket_name: str):
        self._s3 = s3_client
        self._bucket = bucket_name

    def store_invoice_pdf(self, invoice_id: int, pdf_content: bytes) -> str:
        """Store invoice PDF."""
        path = f"invoices/{invoice_id}.pdf"
        self._s3.put_object(
            Bucket=self._bucket,
            Key=path,
            Body=pdf_content,
            ContentType='application/pdf'
        )
        return path

    def get_invoice_pdf(self, invoice_id: int) -> bytes:
        """Retrieve invoice PDF."""
        path = f"invoices/{invoice_id}.pdf"
        response = self._s3.get_object(Bucket=self._bucket, Key=path)
        return response['Body'].read()

    def generate_download_link(self, invoice_id: int) -> str:
        """Generate temporary download link."""
        path = f"invoices/{invoice_id}.pdf"
        return self._s3.generate_presigned_url(
            'get_object',
            Params={'Bucket': self._bucket, 'Key': path},
            ExpiresIn=300  # 5 minutes
        )
```

## Testing Pattern: In-Memory Storage

```python
class InMemoryStorage:
    """Test double for object storage."""

    def __init__(self):
        self._files: dict[str, tuple[bytes, str]] = {}

    def store(self, path: str, content: bytes, content_type: str) -> StoredFile:
        self._files[path] = (content, content_type)
        return StoredFile(path=path, size=len(content), content_type=content_type)

    def retrieve(self, path: str) -> bytes:
        if path not in self._files:
            raise FileNotFoundError(path)
        return self._files[path][0]

    def exists(self, path: str) -> bool:
        return path in self._files

    def delete(self, path: str) -> None:
        self._files.pop(path, None)

    def generate_access_url(self, path: str, expires_in_seconds: int) -> str:
        return f"http://fake-url/{path}?expires={expires_in_seconds}"
```

Use in tests:

```python
def test_store_avatar():
    # Arrange
    storage = InMemoryStorage()
    avatar_storage = UserAvatarStorage(storage)
    content = b"fake-image-data"

    # Act
    path = avatar_storage.store_avatar(
        user_id=123,
        content=content,
        content_type='image/jpeg'
    )

    # Assert
    assert path == "users/123/avatar.jpg"
    assert storage.exists(path)
    assert storage.retrieve(path) == content
```

## Benefits

**Clean boundaries**: Storage operations isolated from business logic.

**Domain language**: Methods describe business operations (store_avatar, get_invoice_pdf), not storage operations.

**Provider-agnostic**: Swap S3 for GCS, Azure, or local filesystem without changing domain code.

**Testability**: Test with InMemoryStorage, no AWS required.

**Path management**: Path construction centralized, consistent across application.

## Key Decisions

**What to expose**: `store`, `retrieve`, `exists`, `delete`, `generate_access_url`. Not multipart uploads, server-side encryption, lifecycle policies until needed.

**What to hide**: Bucket names, AWS credentials, S3-specific exceptions, presigned URL mechanics.

**What stays in domain**: Path construction, file naming, validation rules, content type mapping, access control decisions.

## When to Extend

Add wrapper methods only when needed:
- List files by prefix → add `list_by_prefix(prefix) -> list[str]`
- Copy files → add `copy(source_path, dest_path) -> None`
- Get metadata → add `get_metadata(path) -> dict`

Don't add these preemptively. Wait until a domain need emerges.

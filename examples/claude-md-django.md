# Example CLAUDE.md — Django Project

This example shows a CLAUDE.md for a Django web application using Django REST Framework for APIs, Celery for background tasks, and PostgreSQL. It covers Django-specific conventions for app structure, model patterns, and the ORM that keep Claude Code generating idiomatic Django.

## The CLAUDE.md File

```markdown
# Project: Acme Marketplace

Django 5.1 + Django REST Framework 3.15. Python 3.12+. PostgreSQL database, Redis for caching and Celery broker.

## Setup

- Virtual environment: `source .venv/bin/activate` (always activate first)
- Install deps: `pip install -e ".[dev]"`
- Environment: copy `.env.example` to `.env`
- Database: `docker compose up -d` starts PostgreSQL and Redis

## Commands

- `python manage.py runserver` — start dev server (port 8000)
- `pytest` — run all tests
- `pytest apps/orders/tests/test_views.py::TestCreateOrder -v` — run a single test
- `pytest --cov=apps --cov-report=term-missing` — tests with coverage
- `ruff check .` — lint
- `ruff format .` — format
- `mypy apps/` — type checking
- `python manage.py makemigrations` — generate migrations after model changes
- `python manage.py migrate` — apply migrations
- `celery -A config worker -l info` — start Celery worker

Run `ruff check . && mypy apps/ && pytest` before committing.

## Project Structure

```
config/                     # Django project config
  settings/
    base.py                 # Shared settings
    local.py                # Local dev overrides
    production.py           # Production settings
  urls.py                   # Root URL config
  celery.py                 # Celery app config
apps/                       # Django apps, one per domain
  users/
    models.py               # User model (custom AbstractUser)
    serializers.py          # DRF serializers
    views.py                # DRF viewsets and API views
    urls.py                 # App URL patterns
    services.py             # Business logic (views call services)
    selectors.py            # Complex read queries
    tasks.py                # Celery tasks
    tests/
      test_views.py
      test_services.py
      factories.py          # Factory Boy factories
    admin.py                # Admin site config
  orders/                   # Same structure
  products/                 # Same structure
  core/                     # Shared utilities, base classes, mixins
```

## Architecture Conventions

- **Views are thin.** Views handle HTTP concerns (serialization, permissions, status codes). Business logic lives in `services.py`.
- **Services contain business logic.** Services are plain Python functions or classes. They receive validated data from views and return domain objects.
- **Selectors for complex reads.** Read-heavy queries with joins, annotations, or filters go in `selectors.py`, not in views or services.
- **One app per domain.** Each Django app represents a bounded context. Apps communicate through services, not by importing each other's models directly.

```python
# views.py — thin view
class CreateOrderView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = CreateOrderSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        order = OrderService.create(user=request.user, **serializer.validated_data)
        return Response(OrderSerializer(order).data, status=status.HTTP_201_CREATED)
```

```python
# services.py — business logic
class OrderService:
    @staticmethod
    def create(user: User, product_id: int, quantity: int) -> Order:
        product = Product.objects.get(id=product_id)
        if product.stock < quantity:
            raise InsufficientStockError(product.name)
        order = Order.objects.create(user=user, product=product, quantity=quantity)
        product.stock -= quantity
        product.save(update_fields=["stock"])
        send_order_confirmation.delay(order.id)
        return order
```

## Models

- Custom user model in `apps/users/models.py` extending `AbstractUser`
- Use `models.TextChoices` for enum fields
- Add `__str__`, `Meta.ordering`, and `Meta.verbose_name` on all models
- Use `update_fields` in `.save()` calls to avoid overwriting concurrent changes
- Index frequently queried fields with `db_index=True` or `Meta.indexes`

```python
class Order(models.Model):
    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        CONFIRMED = "confirmed", "Confirmed"
        SHIPPED = "shipped", "Shipped"

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="orders")
    product = models.ForeignKey("products.Product", on_delete=models.PROTECT)
    quantity = models.PositiveIntegerField()
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        indexes = [models.Index(fields=["user", "status"])]

    def __str__(self):
        return f"Order #{self.pk} — {self.status}"
```

## DRF Serializers

- Use `ModelSerializer` for standard CRUD
- Separate serializers for create/update vs. read (e.g., `CreateOrderSerializer`, `OrderSerializer`)
- Validate business rules in the serializer's `validate` method or in the service layer — not both
- Use `SerializerMethodField` sparingly — prefer annotations in selectors for computed fields

## Celery Tasks

- Tasks in `tasks.py` within each app
- Always use `.delay()` or `.apply_async()` — never call task functions directly
- Tasks should be idempotent (safe to retry)
- Use `@shared_task(bind=True, max_retries=3)` with exponential backoff
- Pass IDs to tasks, not full objects (objects cannot be serialized reliably)

```python
@shared_task(bind=True, max_retries=3)
def send_order_confirmation(self, order_id: int) -> None:
    try:
        order = Order.objects.select_related("user", "product").get(id=order_id)
        EmailService.send_confirmation(order)
    except Exception as exc:
        self.retry(exc=exc, countdown=2 ** self.request.retries)
```

## Testing

- pytest + pytest-django + factory_boy
- Factory Boy factories in `tests/factories.py` within each app
- Use `@pytest.mark.django_db` on tests that touch the database
- API tests use DRF's `APIClient`
- Mock external services (email, payment) — never call real APIs in tests
- Aim for >80% coverage on services and views

## Git

- Conventional commits: feat:, fix:, chore:, refactor:
- Always include migrations in the same commit as model changes
- Run `python manage.py makemigrations --check` in CI to catch missing migrations

## Do NOT

- Do not put business logic in views or serializers — use services
- Do not import models from other apps directly — go through services or selectors
- Do not use `objects.raw()` or raw SQL unless the ORM genuinely cannot express the query
- Do not use `print()` — use Django's `logging` module
- Do not use `*` imports
- Do not modify migration files after they have been applied
```

## Key Sections Explained

**Architecture Conventions** — The views-services-selectors pattern is the single most impactful section. Without it, Claude puts business logic in views (the most common Django anti-pattern).

**Models** — The `TextChoices`, `update_fields`, and indexing rules prevent subtle bugs that are hard to catch in code review. The complete model example gives Claude a template for every new model.

**Celery Tasks** — The "pass IDs not objects" and idempotency rules prevent the two most common Celery mistakes. The retry pattern with exponential backoff is included as a copy-paste template.

**Do NOT** — The cross-app import rule enforces bounded contexts. The raw SQL rule keeps the codebase maintainable. These rules catch patterns Claude would otherwise use freely.

## See Also

- [CLAUDE.md Setup Guide](../guides/claude-md-guide.md) — how to structure your own CLAUDE.md
- [Minimal Example](./claude-md-minimal.md) — a simpler starting point
- [Python Example](./claude-md-python.md) — for FastAPI projects
- [Monorepo Example](./claude-md-monorepo.md) — for multi-package setups

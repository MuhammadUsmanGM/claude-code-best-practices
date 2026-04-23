# Example CLAUDE.md — Python Project

This example shows a complete CLAUDE.md for a Python backend service using FastAPI, pytest for testing, and standard Python tooling. It demonstrates conventions for type hints, virtual environments, and project structure.

## The CLAUDE.md File

````markdown
# Project: Inventory API

FastAPI backend service for inventory management. Python 3.12+.

## Setup

- Virtual environment: `source .venv/bin/activate` (always activate before running commands)
- Install deps: `pip install -e ".[dev]"`
- Environment variables: copy `.env.example` to `.env` for local development

## Commands

- `pytest` — run all tests
- `pytest tests/test_items.py::test_create_item -v` — run a single test
- `pytest --cov=src --cov-report=term-missing` — run tests with coverage
- `ruff check .` — lint
- `ruff format .` — format code
- `mypy src/` — type checking
- `uvicorn src.main:app --reload` — start dev server

Run `ruff check . && mypy src/` before committing.

## Project Structure

- `src/` — application source code
  - `src/main.py` — FastAPI app entrypoint and router mounting
  - `src/models/` — SQLAlchemy ORM models
  - `src/schemas/` — Pydantic request/response schemas
  - `src/routers/` — API route handlers, one file per resource
  - `src/services/` — business logic layer (routers call services, services call repositories)
  - `src/repositories/` — database access layer
  - `src/dependencies.py` — FastAPI dependency injection (db sessions, auth)
- `tests/` — mirrors src/ structure: `tests/test_routers/`, `tests/test_services/`, etc.
- `alembic/` — database migrations

## Coding Conventions

- Type hints on all function signatures — parameters and return types
- Use `from __future__ import annotations` at the top of every module
- Pydantic models for all API input/output — never pass raw dicts across boundaries
- Use `pathlib.Path` instead of `os.path`
- f-strings for string formatting (no .format() or % formatting)
- Docstrings on public functions using Google style

```python
def get_item(item_id: int, db: Session) -> Item:
    """Fetch a single item by ID.

    Args:
        item_id: The item's primary key.
        db: Database session.

    Returns:
        The matching Item.

    Raises:
        NotFoundError: If no item matches the ID.
    """
```

## Testing

- Use pytest with fixtures defined in `conftest.py`
- Test database: use an in-memory SQLite or test-specific PostgreSQL database — never touch the dev database
- Use `httpx.AsyncClient` with `app` for API integration tests
- Factory fixtures for creating test data (see `tests/factories.py`)
- Aim for >80% coverage on business logic in `src/services/`

## Database

- SQLAlchemy 2.0 style (use `select()` not `session.query()`)
- All schema changes go through Alembic migrations — never modify tables manually
- New migration: `alembic revision --autogenerate -m "description"`
- Apply migrations: `alembic upgrade head`

## Error Handling

- Use custom exception classes in `src/exceptions.py`
- Routers should not catch generic exceptions — let the global exception handler deal with unexpected errors
- Service layer raises domain exceptions (NotFoundError, ValidationError, etc.)
- Never return error details from unhandled exceptions in production responses

## Git

- Conventional commits: feat:, fix:, chore:
- Run the full check before committing: `ruff check . && ruff format --check . && mypy src/ && pytest`

## Do NOT

- Do not use `import *`
- Do not use `objects.raw()` or raw SQL — use the repository layer
- Do not use `print()` — use the configured `logging` module
- Do not use `*` imports
``````

## Key Sections Explained

**Setup** — The virtual environment reminder is critical. Claude needs to know to activate the venv before running any Python commands.

**Project Structure** — The layered architecture (routers -> services -> repositories) tells Claude where new code should go and prevents it from putting business logic in route handlers.

**Coding Conventions** — Type hints and Pydantic model requirements ensure Claude generates code that passes mypy and follows team standards.

**Database** — Specifying SQLAlchemy 2.0 style prevents Claude from using the older query API. The Alembic instructions ensure schema changes are done properly.

**Do NOT** — Prevents common Python anti-patterns. The `import *` and mutable default argument rules catch issues Claude might otherwise introduce.

## See Also

- [CLAUDE.md Setup Guide](../guides/claude-md-guide.md) — how to structure your own CLAUDE.md
- [Minimal Example](./claude-md-minimal.md) — a simpler starting point
- [React Example](./claude-md-react.md) — for frontend projects

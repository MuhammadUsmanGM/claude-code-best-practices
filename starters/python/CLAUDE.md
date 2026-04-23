# CLAUDE.md

<!-- Starter kit for Python projects (FastAPI, Django, or library). Edit the
     sections marked <!-- edit --> to match your codebase. -->

## Project

<!-- edit --> One-paragraph description of what this service does.

- Framework: <!-- edit --> FastAPI / Django / Flask / library (no framework)
- Python: 3.11+
- Package manager: <!-- edit --> `uv` / `poetry` / `pip-tools`
- Formatter + linter: `ruff` (format and check)
- Type checker: <!-- edit --> `mypy --strict` / `pyright`
- Tests: `pytest`

## Commands

- `ruff format .` — format
- `ruff check .` — lint
- `mypy .` — type-check
- `pytest` — run tests
- `pytest -x --ff` — stop at first failure, reorder to re-run last failures first
- <!-- edit --> `uvicorn app.main:app --reload` — dev server

Before opening a PR: `ruff format .`, `ruff check .`, `mypy .`, `pytest`.
CI runs the same four commands in that order.

## Architecture

<!-- edit --> Describe your layout. Example for a FastAPI service:

- `app/api/` — route handlers. Thin; no business logic.
- `app/services/` — business logic. Pure functions where possible.
- `app/models/` — SQLAlchemy ORM models.
- `app/schemas/` — Pydantic request/response schemas.
- `app/db/` — database session, migrations (Alembic).
- `tests/` — mirrors `app/` structure. `tests/api/test_users.py` covers
  `app/api/users.py`.

## Testing

- One test module per source module. Same relative path under `tests/`.
- Use `pytest` fixtures for setup. No `setUp`/`tearDown`.
- Factory functions for test data live in `tests/factories/`. Don't inline
  a 15-line dict to build a user — add a `user_factory`.
- Database tests use the `transactional_db` fixture. It rolls back after
  each test, so test order doesn't matter.
- Don't mock what you own. Mock external HTTP (`respx`, `httpx_mock`).

## Conventions

- Type hints on every public function signature. Private helpers can skip
  them if the function is obviously trivial.
- `pydantic.BaseModel` for request/response bodies. Never return raw ORM
  objects from an endpoint.
- SQL via the ORM or `sqlalchemy.text()` — no f-string SQL, ever.
- Exceptions: raise domain exceptions in services (`app/errors.py`), catch
  them at the API boundary and map to HTTP codes.

## Do NOT

- Add dependencies without asking. Lockfile is reviewed.
- `except Exception:` without re-raising or a specific reason comment.
- Put business logic in route handlers.
- Commit `.env` files or anything under `.venv/`, `__pycache__/`, `.pytest_cache/`.

## Available skills

- `/api-endpoint` — scaffold a new endpoint: route + Pydantic schemas +
  service function + test, following the project layout.

## See also

- [starters/README.md](../README.md) — kit contents and install
- [../../guides/claude-md-guide.md](../../guides/claude-md-guide.md) — how to
  write a good CLAUDE.md

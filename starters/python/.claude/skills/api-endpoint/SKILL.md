---
name: api-endpoint
description: Scaffold a new API endpoint with request/response Pydantic schemas, service function, route handler, and a pytest test — following the project's layered layout. Invoke when the user asks to add an endpoint, route, or API method.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# API Endpoint

Scaffold one new endpoint across the layers the project already uses. Don't
invent a layer the codebase doesn't have.

## Steps

1. **Ask once** (if not already specified): method + path (e.g. `POST /users`),
   what it does, and the response shape. Do not guess.
2. **Read a sibling endpoint** in `app/api/` (or the project's equivalent) to
   match: router setup, dependency injection, error handling, test file
   layout. If no sibling exists, use the shape below.
3. **Create or edit these files, in order:**
   - `app/schemas/<resource>.py` — request + response Pydantic models.
     If the file exists, add the new models; do not rewrite it.
   - `app/services/<resource>.py` — the pure-ish function that does the
     work. No request/response handling here.
   - `app/api/<resource>.py` — the route handler. Call the service, map
     domain exceptions to HTTP codes.
   - `tests/api/test_<resource>.py` — one happy-path test and one failure
     test (invalid input → 422, or domain error → mapped status).
4. **Register the router** in `app/api/__init__.py` (or the project's
   equivalent) only if adding a new resource file.
5. Run `ruff format` and `ruff check` on the files you touched. Report any
   remaining lint errors; do not auto-fix mypy errors without showing the
   user the diff.

## Default shape (FastAPI)

```python
# app/schemas/widget.py
from pydantic import BaseModel, Field

class WidgetCreate(BaseModel):
    name: str = Field(min_length=1, max_length=80)

class WidgetOut(BaseModel):
    id: int
    name: str
```

```python
# app/services/widgets.py
from app.schemas.widget import WidgetCreate, WidgetOut

def create_widget(db, payload: WidgetCreate) -> WidgetOut:
    widget = Widget(name=payload.name)
    db.add(widget); db.flush()
    return WidgetOut(id=widget.id, name=widget.name)
```

```python
# app/api/widgets.py
from fastapi import APIRouter, Depends
from app.schemas.widget import WidgetCreate, WidgetOut
from app.services import widgets as service

router = APIRouter(prefix="/widgets", tags=["widgets"])

@router.post("", response_model=WidgetOut, status_code=201)
def create(payload: WidgetCreate, db = Depends(get_db)) -> WidgetOut:
    return service.create_widget(db, payload)
```

## Rules

- Don't add new dependencies.
- Type hints on every new function signature.
- Never return the ORM model from a route — always the Pydantic schema.
- Test file must live under `tests/api/` mirroring the source path.
- If the service function needs a new ORM model, stop and ask. Adding a
  table is a separate decision.

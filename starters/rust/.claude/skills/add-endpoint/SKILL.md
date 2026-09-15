---
name: add-endpoint
description: Scaffold a new HTTP endpoint across the project's handler, service, and repository layers with tests, following the existing layering. Invoke when the user asks to add a route, endpoint, or API method to a Rust service.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(cargo check:*), Bash(cargo test:*)
---

# Add Endpoint

Add a new HTTP endpoint across the layers the project already uses. Don't
invent a layer that isn't there.

## Steps

1. **Clarify once** (if not given): method + path, request shape, response
   shape, and status codes for success and failure.
2. **Read one existing endpoint** end to end — handler, service function,
   repository method, and their tests. Mirror the style exactly: error
   mapping, extractor order, naming.
3. **Edit files in this order:**
   - `src/models/<resource>.rs` — request/response types, if new. Derive
     `Debug, Serialize, Deserialize` and `serde(rename_all = "camelCase")`
     on API-facing structs.
   - `src/repositories/<resource>.rs` — store method with a compile-time
     checked `sqlx::query_as!` (or stop here if no storage is needed).
   - `src/services/<resource>.rs` — the business function. Takes domain
     types, returns `Result<_, AppError>`. No HTTP or SQLx types.
   - `src/routes/<resource>.rs` — the handler. Extractors in, service call,
     map `AppError` via the shared `IntoResponse` impl, wrap the response.
   - `src/routes/<resource>.rs` tests — happy path plus one validation
     failure, using the existing test helpers.
4. **Wire the route** in the router setup only if adding a new path.
5. Run `cargo fmt`, then `cargo clippy -- -D warnings`, then
   `cargo test <resource>`. Report the outcome. Do not commit.

## Default shape

```rust
// src/routes/widgets.rs
pub async fn create_widget(
    State(state): State<AppState>,
    Json(payload): Json<CreateWidgetRequest>,
) -> Result<impl IntoResponse, AppError> {
    let widget = state.widget_service.create(payload).await?;
    Ok((StatusCode::CREATED, Json(widget)))
}
```

```rust
// src/routes/widgets.rs (test)
#[tokio::test]
async fn create_widget_returns_201() {
    // build app state from the existing test helpers
    // assert status and decoded body shape
}
```

## Rules

- No new dependencies. `Cargo.toml` is reviewed.
- No `unwrap()` or `expect()` in the new code — tests included if a fixture
  can fail realistically.
- Handlers stay thin: decode, delegate, encode. Business logic belongs in
  the service.
- If the endpoint needs a new repository method, define the signature where
  the service consumes it, implement it in the repository module.
- Follow the project's existing response-envelope convention, if it has
  one. Don't introduce a second response shape.

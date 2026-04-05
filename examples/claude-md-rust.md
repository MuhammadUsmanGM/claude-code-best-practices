# Example CLAUDE.md — Rust Project

This example shows a CLAUDE.md for a Rust web service using Axum for HTTP, SQLx for database access, and Tokio as the async runtime. It covers Rust-specific conventions for error handling, module structure, and the type system that keep Claude Code generating idiomatic Rust.

## The CLAUDE.md File

```markdown
# Project: Acme Order Service

Rust 1.78+ HTTP service for order processing. Axum web framework, SQLx with PostgreSQL, Tokio async runtime.

## Commands

- `cargo run` — start the server (reads .env for config)
- `cargo test` — run all tests
- `cargo test order::tests::test_create_order` — run a single test
- `cargo clippy -- -D warnings` — lint (treat warnings as errors)
- `cargo fmt --check` — check formatting
- `cargo fmt` — auto-format
- `cargo sqlx prepare` — generate offline query metadata for CI
- `docker compose up -d` — start PostgreSQL locally
- `sqlx migrate run` — apply database migrations

Run `cargo fmt && cargo clippy -- -D warnings && cargo test` before committing.

## Architecture

- `src/main.rs` — server startup, router setup, graceful shutdown
- `src/config.rs` — environment-based configuration with typed structs
- `src/routes/` — Axum route handlers, one file per resource (orders.rs, users.rs)
- `src/models/` — domain types and database row structs
- `src/services/` — business logic layer (handlers call services, services call repositories)
- `src/repositories/` — database access using SQLx queries
- `src/errors.rs` — application error types and Axum IntoResponse implementations
- `src/middleware/` — Axum middleware (auth, logging, request ID)
- `src/extractors/` — custom Axum extractors for request parsing
- `migrations/` — SQLx migration files

## Error Handling

Use a unified error type with thiserror:

```rust
#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error("not found: {0}")]
    NotFound(String),
    #[error("validation: {0}")]
    Validation(String),
    #[error("unauthorized")]
    Unauthorized,
    #[error(transparent)]
    Internal(#[from] anyhow::Error),
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, message) = match &self {
            AppError::NotFound(msg) => (StatusCode::NOT_FOUND, msg.clone()),
            AppError::Validation(msg) => (StatusCode::BAD_REQUEST, msg.clone()),
            AppError::Unauthorized => (StatusCode::UNAUTHORIZED, "unauthorized".into()),
            AppError::Internal(_) => (StatusCode::INTERNAL_SERVER_ERROR, "internal error".into()),
        };
        (status, Json(json!({ "error": message }))).into_response()
    }
}
```

All handler return types should be `Result<impl IntoResponse, AppError>`.

## Coding Conventions

- Use `Result<T, AppError>` for all fallible functions — propagate with `?`
- Use `anyhow::Context` for adding context to errors: `.context("failed to fetch order")?`
- Prefer owned types (`String`, `Vec<T>`) in structs; use references (`&str`, `&[T]`) in function parameters when possible
- Derive `Debug`, `Clone`, `Serialize`, `Deserialize` on all public types
- Use `serde(rename_all = "camelCase")` on API-facing structs for JSON compatibility
- Module-level `mod.rs` files export the public interface — keep implementation in submodules
- Use `tracing` for logging, not `println!` or `log`

## Database (SQLx)

- Use compile-time checked queries with `sqlx::query!` and `sqlx::query_as!`
- Migrations in `migrations/` — create with `sqlx migrate add <name>`
- Run `cargo sqlx prepare` after changing queries to update offline metadata
- Use transactions for multi-step operations:

```rust
let mut tx = pool.begin().await?;
sqlx::query!("INSERT INTO orders ...").execute(&mut *tx).await?;
sqlx::query!("UPDATE inventory ...").execute(&mut *tx).await?;
tx.commit().await?;
```

## Axum Handlers

Follow this pattern for all handlers:

```rust
pub async fn create_order(
    State(state): State<AppState>,
    Json(payload): Json<CreateOrderRequest>,
) -> Result<impl IntoResponse, AppError> {
    let order = state.order_service.create(payload).await?;
    Ok((StatusCode::CREATED, Json(order)))
}
```

- Extract state, path params, query params, and body using Axum extractors
- Validate input at the handler level using the validator crate
- Keep handlers thin — delegate to the service layer

## Testing

- Unit tests in `#[cfg(test)] mod tests` blocks within each module
- Integration tests in `tests/` directory using `reqwest` against a test server
- Use `sqlx::test` macro for database tests with automatic rollback
- Factory functions for test data in `tests/helpers/`
- Mock external services with traits and mock implementations

## Git

- Conventional commits: feat:, fix:, chore:, refactor:
- Run the full check before pushing: `cargo fmt --check && cargo clippy -- -D warnings && cargo test`

## Do NOT

- Do not use `unwrap()` or `expect()` in application code — only in tests
- Do not use `unsafe` without a safety comment and team review
- Do not add async runtime dependencies other than Tokio
- Do not use `String` for IDs — use typed wrappers (`OrderId(Uuid)`)
- Do not use `.clone()` to satisfy the borrow checker without trying to fix the ownership first
```

## Key Sections Explained

**Error Handling** — Rust's error handling is the most important thing to get right. The unified `AppError` type with `thiserror` and `anyhow` gives Claude a clear pattern to follow for every fallible function.

**Coding Conventions** — Rust has nuances Claude can miss: when to use owned vs. borrowed types, which derives to add, and the `tracing` vs. `println!` distinction. Being explicit prevents non-idiomatic code.

**Database (SQLx)** — The compile-time query checking and `cargo sqlx prepare` workflow is unique to Rust. Without this section, Claude would not know to update offline metadata after changing queries.

**Do NOT** — The `unwrap()` and `unsafe` rules are critical. Claude sometimes reaches for `unwrap()` to simplify code, and this section prevents that pattern from entering production code.

## See Also

- [CLAUDE.md Setup Guide](../guides/claude-md-guide.md) — how to structure your own CLAUDE.md
- [Minimal Example](./claude-md-minimal.md) — a simpler starting point
- [Go Example](./claude-md-go.md) — for Go microservices
- [Python Example](./claude-md-python.md) — for Python backend projects

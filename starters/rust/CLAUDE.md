# CLAUDE.md

<!-- Starter kit for Rust projects (services with Axum or Actix, libraries,
     CLIs). Edit the sections marked <!-- edit --> to match your codebase. -->

## Project

<!-- edit --> One-paragraph description of what this crate does and who uses it.

- Language: Rust (edition 2021)
- Framework: <!-- edit --> Axum / Actix / CLI (clap) / library crate
- Async runtime: Tokio (services only)
- Database: <!-- edit --> SQLx with PostgreSQL / none
- Tests: built-in `cargo test`, integration tests in `tests/`

## Commands

- `cargo build` — compile all targets
- `cargo test` — run all tests (unit + integration)
- `cargo test <name>` — run tests matching `<name>`
- `cargo clippy -- -D warnings` — lint; warnings are errors
- `cargo fmt` — auto-format; `cargo fmt --check` in CI
- `cargo run` — run the binary (services read config from the environment)
- `cargo sqlx prepare` — refresh offline query metadata (SQLx projects only)

Run `cargo fmt && cargo clippy -- -D warnings && cargo test` before opening a
PR. CI blocks on all three.

## Architecture

- `src/main.rs` — entry point; wiring only, no business logic.
- `src/lib.rs` — crate root; re-exports the public interface.
- `src/routes/` or `src/handlers/` — HTTP layer; thin, delegates downward.
- `src/services/` — business logic; no HTTP types.
- `src/repositories/` — database access; SQLx compile-time checked queries.
- `src/models/` — domain types and row structs.
- `src/errors.rs` — one error enum with `thiserror`; `IntoResponse` impl for HTTP.
- `migrations/` — SQLx migrations; never edit an applied migration.

Handlers call services, services call repositories. Never skip a layer, and
never let HTTP types leak below `routes/`.

## Error Handling

- One unified error type (`AppError`) derived with `thiserror`. All fallible
  functions return `Result<T, AppError>` and propagate with `?`.
- Add context with `anyhow::Context` at the boundary where the error leaves
  the layer that caused it.
- Map error variants to status codes in one place — the `IntoResponse` impl —
  not in individual handlers.

## Conventions

- No `unwrap()` or `expect()` outside tests. Return errors.
- No `unsafe` without a `// SAFETY:` comment and a human reviewer.
- Owned types (`String`, `Vec<T>`) in structs and returns; borrows (`&str`,
  `&[T]`) in function parameters.
- Derive `Debug, Clone, Serialize, Deserialize` on public API types.
- Typed IDs, not raw strings: `OrderId(Uuid)`, not `String`.
- `tracing` for logging. No `println!` in library code.
- Prefer `mod.rs` exporting the public interface; keep implementation in
  sibling modules.

## Testing

- Unit tests live in `#[cfg(test)] mod tests` at the bottom of each module.
- Integration tests live in `tests/<feature>.rs` and exercise the public API.
- SQLx projects: use `#[sqlx::test]` for automatic per-test rollback.
- Build test data through constructor functions, not hand-built structs at
  every call site.

## Do NOT

- Add dependencies without asking. `Cargo.toml` is reviewed.
- Use `.clone()` to silence the borrow checker without trying ownership fixes
  first.
- Block the async runtime: no `std::fs` or blocking IO inside async contexts —
  use `tokio::fs` or `spawn_blocking`.
- Commit `target/` or `Cargo.lock` changes unrelated to your dependency edit.

## Available skills

- `/add-endpoint` — scaffold a route across handlers, services, and
  repositories with tests, following the project's layering.

## See also

- [starters/README.md](../README.md) — how this kit was assembled and how to
  adapt it
- [../../guides/claude-md-guide.md](../../guides/claude-md-guide.md) — how to
  write a good CLAUDE.md

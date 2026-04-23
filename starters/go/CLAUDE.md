# CLAUDE.md

<!-- Starter kit for Go services. Edit the sections marked <!-- edit --> to
     match your codebase. -->

## Project

<!-- edit --> One-paragraph description of what this service does.

- Go version: 1.22+
- HTTP: <!-- edit --> stdlib `net/http` / `chi` / `echo` / `gin`
- Database: <!-- edit --> `database/sql` + `sqlc` / `pgx` / `gorm`
- Tests: standard `testing` + `testify/assert` where it genuinely helps
- Lint: `golangci-lint`

## Commands

- `go build ./...` — build all packages
- `go test ./...` — run all tests
- `go test -race ./...` — run with the race detector (CI does this too)
- `go vet ./...` — vet
- `golangci-lint run` — full lint pass
- `gofmt -w .` — format

Before opening a PR: `gofmt -w .`, `golangci-lint run`, `go test -race ./...`.

## Architecture

<!-- edit --> Describe your layout. Example for a standard service:

- `cmd/<service>/main.go` — binary entrypoint, flag parsing, wiring.
- `internal/api/` — HTTP handlers. Thin.
- `internal/service/` — business logic. Pure where possible.
- `internal/store/` — database access. Interface lives in `service`,
  implementation lives here.
- `internal/model/` — domain types, no framework imports.
- `internal/*` is enforced-private by the Go toolchain. Keep it that way.

## Testing

- One test file per package, colocated: `foo.go` → `foo_test.go`.
- Table-driven tests by default. Name rows with a `name` field.
- Use `t.Helper()` in test helpers so failure reports point at the caller.
- Integration tests: build tag `//go:build integration`, run via
  `go test -tags integration ./...`. Unit tests stay pure.
- Don't mock the database. Run against a real ephemeral Postgres (see
  `testcontainers-go` in a similar repo if you need a reference).

## Conventions

- Errors: return, don't panic. Wrap with `fmt.Errorf("doing X: %w", err)`.
- Context is the first argument of every function that does I/O.
- No `interface{}` / `any` unless the value truly can be anything (JSON
  decoding, reflection). Prefer generics or a concrete type.
- Exported symbols get doc comments starting with the symbol's name.
  `golangci-lint` enforces this.

## Do NOT

- Add dependencies without asking. `go.mod` is reviewed; transitive deps
  matter.
- Use `init()` except for registering drivers or flags.
- Start goroutines without a clear lifetime — every goroutine needs either
  a bounded runtime or a context that cancels it.
- Commit `vendor/` unless the team has explicitly opted into vendoring.

## Available skills

- `/add-handler` — scaffold a new HTTP handler + service function + store
  method + test, with the right package boundaries.

## See also

- [starters/README.md](../README.md) — kit contents and install
- [../../guides/claude-md-guide.md](../../guides/claude-md-guide.md) — how to
  write a good CLAUDE.md

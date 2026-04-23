---
name: add-handler
description: Scaffold a new HTTP handler with service function, store method (if needed), and table-driven test, following the project's internal/{api,service,store} layout. Invoke when the user asks to add an endpoint, handler, or route.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(go build:*), Bash(go test:*)
---

# Add Handler

Add a new HTTP handler across the layers the project already uses. Don't
invent a layer that isn't there.

## Steps

1. **Clarify once** (if not given): method + path, what it does, and the
   response shape.
2. **Read one existing handler** in `internal/api/` and its matching test
   and service function. Mirror the style: error handling, context usage,
   response helpers.
3. **Edit files in this order:**
   - `internal/model/<resource>.go` — domain type, if new.
   - `internal/store/<resource>.go` — store method signature on the
     interface *and* the concrete implementation. Stop here if the
     operation doesn't need storage.
   - `internal/service/<resource>.go` — the service function. Takes a
     context, returns the domain type and an error. No `http` imports.
   - `internal/api/<resource>.go` — the handler. Decodes input, calls the
     service, maps errors to status codes, encodes output.
   - `internal/api/<resource>_test.go` — a table-driven test exercising
     happy path and one input-validation failure.
4. **Wire the route** in the router setup (usually `cmd/<service>/main.go`
   or `internal/api/router.go`) only if adding a new path.
5. Run `go build ./...` then `go test ./internal/api/...` and report the
   outcome.

## Default shape

```go
// internal/api/widgets.go
func (s *Server) createWidget(w http.ResponseWriter, r *http.Request) {
    var in WidgetCreate
    if err := json.NewDecoder(r.Body).Decode(&in); err != nil {
        http.Error(w, "invalid body", http.StatusBadRequest)
        return
    }
    widget, err := s.svc.CreateWidget(r.Context(), in)
    if err != nil {
        s.writeErr(w, err)  // maps domain errors to status codes
        return
    }
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusCreated)
    _ = json.NewEncoder(w).Encode(widget)
}
```

```go
// internal/api/widgets_test.go
func TestCreateWidget(t *testing.T) {
    cases := []struct {
        name       string
        body       string
        wantStatus int
    }{
        {"happy", `{"name":"gizmo"}`, http.StatusCreated},
        {"empty name", `{"name":""}`, http.StatusBadRequest},
    }
    for _, tc := range cases {
        t.Run(tc.name, func(t *testing.T) {
            // ...
        })
    }
}
```

## Rules

- No new dependencies. `go.mod` is reviewed.
- `r.Context()` is passed to every downstream call.
- Exported funcs/types get a doc comment starting with their name.
- If the handler needs a new store method, add the interface method in
  `internal/service/` (where the interface is consumed), not `internal/store/`
  (where it's implemented).
- Don't wrap the router middleware. Follow the project's existing wiring.

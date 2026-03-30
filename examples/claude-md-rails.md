# Example CLAUDE.md — Ruby on Rails Project

This example shows a CLAUDE.md for a Rails 8 application using Hotwire for interactivity, Solid Queue for background jobs, and RSpec for testing. It covers the conventions that keep Claude Code generating idiomatic Rails code.

## The CLAUDE.md File

```markdown
# Project: Acme Marketplace

Rails 8 + Ruby 3.3 + PostgreSQL. Hotwire (Turbo + Stimulus) for frontend. Deployed on Kamal.

## Commands

- `bin/dev` — start dev server (Procfile.dev: Rails + CSS + JS)
- `bin/rails test` — run all Minitest tests
- `bundle exec rspec` — run all RSpec tests
- `bundle exec rspec spec/models/user_spec.rb` — single test file
- `bundle exec rspec spec/models/user_spec.rb:42` — single test by line
- `bin/rubocop` — lint check
- `bin/rubocop -a` — auto-fix lint issues
- `bin/rails db:migrate` — apply pending migrations
- `bin/rails db:rollback` — undo last migration

Always run `bin/rubocop` before committing.

## Architecture

- `app/models/` — ActiveRecord models with validations and scopes
- `app/controllers/` — thin controllers, business logic lives in models or services
- `app/services/` — service objects for complex operations (Checkout, Onboarding, etc.)
- `app/views/` — ERB templates organized by controller
- `app/components/` — ViewComponent classes for reusable UI
- `app/jobs/` — Solid Queue background jobs
- `app/mailers/` — ActionMailer classes
- `config/routes.rb` — all routes, RESTful resources only

## Rails Conventions

- Follow Rails conventions — if Rails has a way to do it, use that way
- Thin controllers: no more than 5 lines per action. Extract to service objects.
- Fat models are OK for queries and validations, but extract complex logic to concerns or services
- Use `has_many :things, dependent: :destroy` — always specify dependent behavior
- Scopes over class methods for reusable queries
- Use Strong Parameters in every controller action that accepts input

## Database

- Migrations live in `db/migrate/` — always use `bin/rails generate migration`
- Never edit `db/schema.rb` manually — it is auto-generated
- Add database-level constraints (NOT NULL, unique indexes) in addition to model validations
- Use `add_index` for any column used in WHERE clauses or joins
- Foreign keys: always add `add_foreign_key` in migrations

## Frontend (Hotwire)

- Use Turbo Frames for partial page updates — no full-page reloads for navigation
- Use Turbo Streams for real-time updates and form responses
- Stimulus controllers in `app/javascript/controllers/` — keep them small and focused
- No React, Vue, or other SPA frameworks — Hotwire handles all interactivity
- CSS: Tailwind CSS via cssbundling-rails

## Testing

- RSpec for model, request, and system tests
- FactoryBot for test data — factories in `spec/factories/`
- Use `let` and `subject` for setup, `before` blocks for shared state
- Request specs over controller specs — test the full HTTP cycle
- System tests with Capybara for critical user flows only (login, checkout, signup)
- Mock external services with WebMock — no real HTTP calls in tests

## Background Jobs

- Use Solid Queue for all async work (emails, webhooks, reports)
- Job classes in `app/jobs/` — keep them thin, delegate to service objects
- Always set `retry_on` with reasonable limits and backoff
- Log job arguments for debugging: `logger.info "Processing order #{order_id}"`

## Git

- Conventional commits: feat:, fix:, chore:, refactor:
- Scope by domain: `feat(orders): add bulk discount pricing`
- One migration per PR when possible

## Do NOT

- Do not use `skip_before_action` to bypass auth — create a separate unprotected controller
- Do not edit `db/schema.rb` manually
- Do not add JavaScript SPA frameworks — use Hotwire
- Do not use `update_column` or `update_all` unless you explicitly intend to skip validations and callbacks
- Do not use `find_by_sql` — use ActiveRecord query interface or Arel
```

## Key Sections Explained

**Rails Conventions** — "Follow Rails conventions" seems obvious but Claude sometimes invents non-standard patterns. The thin controller rule and service object pattern keep code organized.

**Database** — "Never edit schema.rb" is critical. Claude may try to add columns directly to the schema file instead of creating a migration.

**Frontend (Hotwire)** — Explicitly blocking SPA frameworks prevents Claude from suggesting React or Vue when Hotwire is the team's choice. The Turbo Frames/Streams guidance helps Claude use the right tool for each interaction pattern.

**Background Jobs** — The `retry_on` rule prevents Claude from creating jobs that fail silently or retry infinitely.

## See Also

- [CLAUDE.md Setup Guide](../guides/claude-md-guide.md) — how to structure your own CLAUDE.md
- [Minimal Example](./claude-md-minimal.md) — a simpler starting point
- [React Example](./claude-md-react.md) — for React SPA projects
- [Python Example](./claude-md-python.md) — for Python backend projects

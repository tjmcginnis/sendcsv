# AGENTS.md

This file provides comprehensive guidance to AI coding agents working with this repository.

## Project Overview

SendCSV is a CSV data ingestion application built with Rails 8.1, SQLite, Hotwire (Turbo + Stimulus), Tailwind CSS, and Propshaft for assets. It uses Solid Queue, Solid Cache, and Solid Cable for background jobs, caching, and websockets.

**Core Purpose**: Allow users to create tables and ingest CSV data via public URLs. Each table gets a unique URL for CSV uploads, with append-only headers and daily row limits.

## CSV Processing Flow

### Upload Endpoint
**Route**: `POST /in/:table_id` → IngestionsController#create

**Key Characteristics**:
- Unauthenticated access (public CSV ingestion endpoint)
- CSRF protection skipped (for API usage)
- Rate limited: 5 requests per second
- Content-Type must be "text/csv"
- Body size limit: 256KB

### Processing Flow (Synchronous)
1. Create ingestion record with status: :pending
2. Call `ingestion.process(raw_csv)` synchronously (NO background job)
3. Inside `Ingestion#process` (app/models/ingestion.rb):
   - Parse CSV with headers
   - Update/validate table header (append-only check)
   - Change status to :processing
   - Prepare row data for bulk insert
   - Validate daily row limit (10,000 rows)
   - Bulk insert via `Row.insert_all`
   - Update cache counter
   - Set status to :completed
4. On error: set status to :failed with error_message
5. Return JSON with ingestion_id or error

**Important**: Despite Solid Queue being available, CSV processing happens in-request for simplicity given the 256KB limit.

## Testing Patterns

### Framework
- **Minitest** (Rails default)
- **Mocha** for stubbing/mocking
- **Capybara + Selenium** for system tests
- **Fixtures** for all models
- Parallel test execution enabled

### Test Types

**Unit Tests** (test/models/)
- Pattern: Setup fixtures, test business logic methods
- Uses Mocha for stubbing: `@table.stubs(:daily_row_count).returns(10_000)`
- Coverage: happy path, error cases, validation, edge cases

**Integration Tests** (test/controllers/)
- Pattern: POST/GET requests, assert response codes and JSON
- Uses `sign_in_as(user)` helper for authenticated requests
- Coverage: create actions, validations, error responses

**System Tests** (test/system/)
- Capybara + Selenium (headless Chrome)
- Screen size: 1400x1400
- Pattern: End-to-end user flows
- Uses `sign_in_as(email, password)` system helper
- Examples: Sign in → navigate → view table → check UI

### Test Helpers (test/test_helpers/)
- **SessionTestHelper**: `sign_in_as(user)` for integration tests
- **SystemTestHelper**: `sign_in_as(email, password)` for system tests

### Test Naming Convention
Use descriptive names: `test "processing appends rows from csv"`

## Code Style & Conventions

### Model Patterns
- Use concerns for shared behavior (PublicIdGenerator, Authentication)
- Define custom error classes (HeaderMismatchError, DailyLimitExceededError)
- Use enums for status fields
- JSON columns for flexible data (header, contents)
- Validations in models, not controllers

### Controller Patterns
- `allow_unauthenticated_access` for public endpoints
- Rate limiting: `rate_limit to: 5, within: 1.second`
- Private methods for request validation and context setup
- JSON API responses for public endpoints (ingestions)
- RESTful actions (index, show, create, update, destroy)

### View Patterns
- ERB templates with Tailwind CSS utility classes
- Stimulus controllers for progressive enhancement
- Content blocks for flexible layouts
- Dark mode support throughout
- Partials for reusable components

### Testing Patterns
- Fixtures for all models
- Integration tests for all API endpoints
- System tests for critical user journeys
- Mocha for stubbing external dependencies
- Descriptive test names focusing on behavior

### Database Patterns
- Foreign keys with `null: false` for required relationships
- Indexes on foreign keys and frequently queried columns
- JSON columns for flexible/nested data
- String limits to prevent abuse (name: 255 chars)

## Common Commands

### Development
- `bin/setup` - Install dependencies, prepare database, start dev server
- `bin/dev` - Start development server with foreman (Rails + Tailwind watcher)
- `bin/rails console` - Rails console
- `bin/rails dbconsole` - SQLite console

### Testing & CI
- `bin/rails test` - Run unit/integration tests
- `bin/rails test:system` - Run system tests (Capybara + Selenium)
- `bin/rails test test/path/file_test.rb` - Run a single test file
- `bin/rails test test/path/file_test.rb:10` - Run test at specific line
- `bin/ci` - Run full CI suite (setup, lint, security, tests)

### Linting & Security
- `bin/rubocop` - Run RuboCop (uses rubocop-rails-omakase)
- `bin/rubocop -a` - Auto-fix RuboCop violations
- `bin/rubocop -A` - Auto-fix including unsafe corrections
- `bin/brakeman` - Run security analysis
- `bin/bundler-audit` - Audit gems for vulnerabilities
- `bin/importmap audit` - Check importmap dependencies

### Database
- `bin/rails db:prepare` - Create and migrate database
- `bin/rails db:migrate` - Run pending migrations
- `bin/rails db:rollback` - Rollback last migration
- `bin/rails db:reset` - Drop, recreate, and seed database
- `bin/rails db:seed` - Load seed data

### Deployment
- Uses Kamal for Docker-based deployment
- `bin/kamal deploy` - Deploy to production
- Kamal aliases: `console`, `shell`, `logs`, `dbc` (database console)

## Architecture & Design Decisions

**Key Architectural Choices**:

1. **Synchronous CSV Processing**: CSV processing happens in-request (not background jobs) because 256KB limit makes this viable and keeps architecture simple

2. **Public Ingestion Endpoint**: CSV uploads are unauthenticated via unique table URLs (public_id acts as shared secret)

3. **Append-Only Headers**: Table headers can only grow, never change existing columns (ensures data consistency across ingestions)

4. **Daily Row Limits**: 10,000 rows per table per day with cache-based tracking (prevents abuse without complex billing)

5. **NanoIDs for Public IDs**: 12-character public IDs for URL-friendly, non-sequential identifiers (more secure than auto-increment)

6. **No Active Storage**: CSV data stored directly as JSON in rows table (simple, queryable, no file storage complexity)


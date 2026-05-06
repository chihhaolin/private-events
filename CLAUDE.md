# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

Rails 8.1.3 on Ruby 3.4.6. Application module: `PrivateEvents`. This is a learning project from The Odin Project — see `README.md` for context, `docs/project.md` for the original spec, and `docs/scope.md` for the agreed Tier 1–3 split. The pedagogical goal is **custom ActiveRecord associations**, so the naming below is deliberately not derivable from convention.

**Tier 1 is built.** Three domain models (`User`, `Event`, `Registration`), Devise auth, full CRUD-lite for events, register/cancel-register flow, user profile. Tier 2 (past/future split, private events + invitations, navbar) and Tier 3 (edit/delete events, toggle public/private) are not yet started.

## Common commands

Bootstrap, run, test, lint:

```bash
bin/setup                         # install gems, prepare DB, clear logs, then exec bin/dev
bin/setup --skip-server           # same, but don't start the server
bin/dev                           # start development server (Puma)
bin/rails db:prepare              # create + migrate (or load schema) for any pending DBs
bin/rails db:test:prepare test    # what CI runs for unit/integration tests
bin/rails db:test:prepare test:system   # what CI runs for system tests
bin/rails test test/models/foo_test.rb        # single file
bin/rails test test/models/foo_test.rb:42     # single test at line 42
bin/rubocop -a                    # lint + autocorrect (omakase rules)
bin/brakeman --no-pager           # static security scan
bin/bundler-audit                 # gem CVE scan (config: config/bundler-audit.yml)
bin/importmap audit               # JS dependency CVE scan
bin/ci                            # run the whole CI suite locally (see config/ci.rb)
```

`bin/jobs` runs the Solid Queue worker out-of-process when you need background jobs in development; in production the Dockerfile launches Solid Queue inside Puma via `SOLID_QUEUE_IN_PUMA=true`.

## Architecture notes worth knowing up front

**Rails 8 "no Redis, no Node" stack.** The three Solid adapters back Rails infrastructure with SQLite instead of Redis: `solid_cache` (Rails.cache), `solid_queue` (Active Job), `solid_cable` (Action Cable). Each has its own SQLite database in production — see `config/database.yml`, which defines four databases (`primary`, `cache`, `queue`, `cable`) with separate `migrations_paths` (`db/cache_migrate`, `db/queue_migrate`, `db/cable_migrate`). Schemas for the non-primary databases live in `db/{cache,queue,cable}_schema.rb`. Development and test use only the primary SQLite file.

**Frontend has no bundler.** JavaScript is served via `importmap-rails` (pin map in `config/importmap.rb`, no `package.json`, no npm). Turbo + Stimulus provide the SPA-ish behavior; Propshaft (not Sprockets) is the asset pipeline. `bin/importmap audit` is the JS dep scanner — there is no `npm audit` equivalent because there are no node_modules.

**Testing.** Minitest with `parallelize(workers: :number_of_processors)` and `fixtures :all` auto-loaded in `test/test_helper.rb`. System tests use Capybara + Selenium. CI splits into five jobs in `.github/workflows/ci.yml`: `scan_ruby` (brakeman), `scan_js` (importmap audit), `lint` (rubocop), `test`, `system-test` — match these locally before pushing.

**Style.** RuboCop inherits from `rubocop-rails-omakase` (`.rubocop.yml`). House overrides go in that file; don't fight omakase defaults without a reason.

**Deploy.** Kamal (`config/deploy.yml`, `.kamal/`) + Thruster (HTTP cache/compression in front of Puma). The Dockerfile is multi-stage and assumes SQLite volumes mounted at `./storage`. `config/credentials.yml.enc` is committed; `config/master.key` is gitignored and required to decrypt — never check it in.

## Domain conventions worth knowing before editing models

**The custom-named associations are the whole point — don't "fix" them to match Rails defaults.**

```
User has_many :created_events, class_name: "Event", foreign_key: "creator_id"
User has_many :registrations
User has_many :attended_events, through: :registrations, source: :event
Event belongs_to :creator, class_name: "User"
Event has_many :registrations
Event has_many :attendees, through: :registrations, source: :user
```

When a controller creates an event, it must use `current_user.created_events.build(...)` — not `Event.new(...)`. The Odin lesson tests for this idiom; reviewers will flag a regression to `Event.new`.

## Devise + Turbo

Devise 4.9 is wired with `data: { turbo: false }` on the three auth forms (`devise/sessions/new.html.erb`, `devise/registrations/new.html.erb`, and the Log out `button_to` in the application layout). This is intentional — it dodges Devise/Turbo redirect-on-422 friction. Don't remove the attribute when editing those views.

Devise's own `RegistrationsController` (sign-up) lives at `/users` under `devise_for`. The app's **event** registration controller is named `EventRegistrationsController` and is wired via `resource :registration, controller: "event_registrations"` in `config/routes.rb` to avoid the name collision. If you add Devise modules later (e.g. confirmable), keep the namespacing in mind.

A harmless deprecation warning prints on boot — `resource received a hash argument …` from `config/routes.rb:2` (the `devise_for :users` line). The warning comes from inside Devise itself preparing for Rails 8.2's keyword-only API. Not actionable here; will go away when Devise releases a fix.

## Test fixtures with Devise

User fixtures need a real bcrypt hash for `encrypted_password`, generated via Devise's encryptor:

```yaml
alice:
  encrypted_password: <%= Devise::Encryptor.digest(User, "password123") %>
```

Integration tests get `sign_in user` / `sign_out` helpers via `include Devise::Test::IntegrationHelpers` in `test/test_helper.rb`. `ActiveSupport::TestCase` does **not** include those — sign-in inside a model test will not work and isn't needed.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

Freshly generated Rails 8.1.3 skeleton on Ruby 3.4.6. The application module is `PrivateEvents` (`config/application.rb`). `config/routes.rb` only declares the `/up` health check, and `app/models`/`app/controllers` contain only the default `ApplicationRecord`/`ApplicationController` — domain code has not been written yet, so most "where is X" questions about features won't have an answer in the tree.

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

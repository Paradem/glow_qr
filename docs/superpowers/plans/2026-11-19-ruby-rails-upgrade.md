# Ruby and Rails Upgrade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use rubypowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade to stable Ruby 4.0.10 and Rails 8.1.4.1 with macOS development support and unchanged Linux deployment support.

**Architecture:** Keep the existing Rails 8.1 defaults and application code. Use `.ruby-version` as the Gemfile's Ruby source and match the Docker image to it; conservatively update Rails and preserve other locked versions.

**Tech Stack:** Ruby, Bundler 4.0.3, Rails 8.1, SQLite, ImageMagick, libvips.

---

### Task 1: Establish a usable baseline

**Files:** `Gemfile.lock` (platform entries and checksums only).

- [x] Add the local Apple Silicon macOS platform without updating existing gem versions:
  `mise exec ruby@4.0.0 -- ruby -S bundle lock --add-platform arm64-darwin-25`.
- [x] Install with `BUNDLE_FROZEN=true mise exec ruby@4.0.0 -- ruby -S bundle install`.
- [x] Run `BUNDLE_FROZEN=true mise exec ruby@4.0.0 -- ruby -S bundle exec ruby bin/rails test`.
  Result: 26 tests, 141 assertions, no failures/errors/skips. Baseline RuboCop: 45 files, no offenses.
- [x] Install the same bundle on Ruby 4.0.10 and run the same tests with `mise exec ruby@4.0.10`.
  Result: 26 tests, 141 assertions, no failures/errors/skips, still on Rails 8.1.3.

### Task 2: Update the toolchain

**Files:** `.ruby-version`, `Dockerfile`, `Gemfile`, `Gemfile.lock`.

- [x] Set `.ruby-version` to `ruby-4.0.10` and Dockerfile's `ARG RUBY_VERSION=4.0.10`.
- [x] Replace the Gemfile Ruby requirement with `ruby file: ".ruby-version"`; include `.ruby-version` in Docker's Gemfile COPY before `bundle install`.
- [x] Set `gem "rails", "~> 8.1.4", ">= 8.1.4.1"`, matching the upstream template.
- [x] Run `mise exec ruby@4.0.10 -- ruby -S bundle _4.0.3_ update rails --ruby --conservative`.
  Only Rails and its required sanitizer dependency chain changed: rails-html-sanitizer 1.7.2, loofah 2.25.3, and nokogiri 1.19.7. Linux platforms and Bundler 4.0.3 were preserved.

### Task 3: Verify the result

**Tests:** Existing `test/models`, `test/controllers`, `test/services`, and `test/qr_templates`.

- [x] Run frozen `bundle check`, `ruby bin/rails test`, and `ruby bin/rubocop` under Ruby 4.0.10/Bundler 4.0.3.
  Result: 26 tests/141 assertions, no failures/errors/skips; 45 files, no RuboCop offenses.
- [x] Run `ruby bin/rails zeitwerk:check` and production `assets:precompile` with a dummy secret key.
  Both passed; generated build output was cleaned and tracked CSS restored to its original content.
- [x] Review `git diff --check`, version consistency, platform preservation, and the full diff.
  Assertions verified every Rails component, Ruby/Docker/lockfile pins, unchanged Bundler, retained Linux platforms, and the allowed dependency changes. An isolated reproduction evaluated the Gemfile from only Docker's bundle-layer COPY inputs.
- [x] Record final results and remaining limits in `docs/ruby-upgrade/2026-11-19/analysis.md`.

Deployment, database migrations, new test dependencies, and unrelated gem updates are outside the upgrade scope. The Docker daemon was unavailable during verification, so container validation remains unverified.

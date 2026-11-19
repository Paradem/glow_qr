# Ruby and Rails upgrade assessment — 2026-11-19

## TL;DR

**Low application-code risk:** patch upgrades from Ruby 4.0.0 to 4.0.10 and Rails 8.1.3 to 8.1.4.1. The Linux-only lockfile initially blocked macOS testing; adding the local platform resolved that. No application compatibility changes were identified. Docker validation is blocked by the unavailable local daemon.

Targets were verified against [Ruby releases](https://www.ruby-lang.org/en/downloads/releases/) and the [Rails RubyGems API](https://rubygems.org/api/v1/versions/rails.json). The user approved macOS support and these upgrades.

## Current state before upgrade

| Component | Version/configuration |
|---|---|
| `.ruby-version`, Dockerfile, lockfile Ruby | 4.0.0 |
| Gemfile Ruby requirement | >= 3.1.0 (stale; replace with `.ruby-version` source) |
| Rails | 8.1.3, Gemfile `~> 8.1.1` |
| Framework defaults | 8.1; no pending framework-default initializers |
| Bundler | 4.0.3; retain |
| Native gems | bootsnap 1.23.0, ffi 1.17.4, msgpack 1.8.0, nokogiri 1.19.2, puma 8.0.0, sqlite3 2.9.2 |
| Other relevant gems | debug 1.11.1, irb 1.17.0, reline 0.6.3, logger 1.7.0, ostruct 0.6.3 |
| Sorbet, OpenSSL pins, literal CI Ruby pins | None |
| RuboCop Ruby override | None; infer from `.ruby-version` |
| Image processing | ruby-vips 2.3.0; local libvips 8.18.2; ImageMagick 7.1.2-25 |

## Ruby risk inventory

Tracked Ruby, ERB, configuration, Gemfile/lockfile, Dockerfile, and bin scripts were scanned directly. Change numbers refer to the ruby-upgrade skill's Ruby 4.0 inventory. This project already runs Ruby 4.0, so major-version removals are not newly introduced by this patch upgrade.

| Change | Exposure | Risk/action |
|---|---|---|
| 01 Net::HTTP write headers | 0 matches; no HTTP wrapper gems | None |
| 02 Removed CGI APIs | 0 matches | Do not add cgi |
| 03 Demoted library requires | 0 direct requires | Do not add gems |
| 04 Set/SortedSet | 0 matches | None |
| 05 Set inspect assertions | 0 matches | None |
| 06 Pipe-form open | 0 matches | None |
| 07 Process status bitwise operations | 0 matches | None |
| 08 OpenSSL/auth gem pins | 0 matches | None |
| 09 Native extensions | 24 lockfile spec entries including platform variants; `Gemfile.lock:83` bootsnap, `:108` ffi | Native gems installed and loaded on both Ruby patches; Docker still unverified |
| 10 Error tracker/backtrace parsing | 0 matches | No monitoring integration to update |
| 11 Ractor | 0 matches | None |
| 12 Frozen literal headers | 16/46 Ruby files have headers | No header churn; patch upgrade only |
| 13 Stale URI escaping | 0 matches | None |
| 14 Experimental JIT flags | 0 matches | Preserve existing Rails YJIT defaults |

## Rails assessment

The [railsdiff comparison](https://api.github.com/repos/railsdiff/rails-new-output/compare/v8.1.3...v8.1.4.1) changes only the Gemfile Rails requirement to `~> 8.1.4`, `>= 8.1.4.1`. No infrastructure/configuration/defaults transition is required. Rails 8.1 removal/deprecation scans found no affected custom code.

Active Storage uses the default vips processor. The sole attachment call (`app/models/qr_code.rb:61`) attaches server-generated PNG bytes, not uploaded images. There are no custom variant types or variant calls. Local libvips and ruby-vips exceed the security patch's requirements; the Dockerfile installs libvips from the base distribution and its runtime version remains to be checked when building.

## Phased checklist and results

- [x] Add Apple Silicon macOS to the lockfile; preserve all existing gem versions and Linux platforms.
- [x] Baseline Ruby 4.0.0/Rails 8.1.3: 26 tests, 141 assertions, 0 failures/errors/skips; RuboCop: 45 files, 0 offenses.
- [x] Baseline Ruby 4.0.10/Rails 8.1.3: 26 tests, 141 assertions, 0 failures/errors/skips.
- [x] Synchronize Ruby pins and conservatively update Rails. Docker copies `.ruby-version` before installing the bundle because the Gemfile now reads that file.
- [x] Verify final bundle, tests, lint, autoloading, and production assets.

Final Ruby 4.0.10/Rails 8.1.4.1 checks: frozen bundle satisfied; 26 tests, 141 assertions, 0 failures/errors/skips; RuboCop 45 files, 0 offenses; Zeitwerk eager loading passed; production assets compiled successfully with a dummy secret key. Generated verification assets were cleaned without retaining CSS changes. Pin/platform/dependency assertions and `git diff --check` passed. An isolated directory containing only Docker's bundle-layer COPY inputs successfully evaluated the Gemfile and validated the Ruby requirement.

Rails 8.1.4.1 requires rails-html-sanitizer >= 1.7.2, which requires loofah >= 2.25.3, which requires nokogiri >= 1.19.5. Resolution selected nokogiri 1.19.7; these were the only non-Rails version changes. Bundler 4.0.3 and all prior Linux platforms were retained, with arm64-darwin-25 added. Docker Hub confirms the `ruby:4.0.10-slim` tag exists for Linux amd64 and arm64, but this does not verify a container build.

Implementation steps: `docs/superpowers/plans/2026-11-19-ruby-rails-upgrade.md`.

## Surprises and remaining limits

The environment defaults to Ruby 4.0.10 while the project originally pinned 4.0.0. Explicit `mise exec` and `ruby bin/rails` avoid interpreter selection problems during baseline checks. The separate browser system-test helper is not configured with a browser test dependency; the baseline command excludes `test/system`, as Rails normally does. No system-test dependency will be introduced for a patch upgrade.

## Open deployment questions

- Rebuild and smoke-test the Fly.io container, confirming libvips >= 8.13 and generated QR downloads before deploying; the local Docker daemon is not running.
- No production error tracker is configured. Check production boot/generation errors after deployment; deployment is outside this task.

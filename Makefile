.PHONY: check test lint-shell validate-skills validate-cursor-skills validate-openspec validate-symlinks check-tracked-ignored install-hooks sync-saski-repos sync-saski-repos-apply discover-saski-repos

export PATH := $(HOME)/.agents/bin:$(HOME)/.bun/bin:/opt/homebrew/bin:/usr/local/bin:$(PATH)

SHELL_SCRIPTS := \
	setup-symlinks.sh \
	sync-saski-repos.sh \
	sync-skill-factory.sh \
	pull-and-sync-skills.sh \
	backup-cursor-config.sh \
	validate-skill-library.sh \
	validate-cursor-skills.sh \
	.agents/skills/openspec/scripts/install-openspec \
	tests/openspec-install-test.sh \
	tests/validate-skill-library-test.sh \
	tests/external-skill-references-test.sh \
	tests/healthcheck-automation-test.sh \
	tests/rtk-global-contract-test.sh \
	tests/cursor-skills-validation-test.sh \
	hooks/pre-commit

check: test lint-shell validate-skills validate-cursor-skills validate-openspec validate-symlinks check-tracked-ignored

test:
	./tests/openspec-install-test.sh
	./tests/validate-skill-library-test.sh
	./tests/external-skill-references-test.sh
	./tests/healthcheck-automation-test.sh
	./tests/rtk-global-contract-test.sh
	./tests/cursor-skills-validation-test.sh

lint-shell:
	bash -n $(SHELL_SCRIPTS)

validate-skills:
	./validate-skill-library.sh

validate-cursor-skills:
	./validate-cursor-skills.sh

validate-openspec:
	@command -v openspec >/dev/null 2>&1 || { printf '%s\n' "openspec CLI is required; install OpenSpec before running make check"; exit 1; }
	OPENSPEC_TELEMETRY=0 openspec validate --all

validate-symlinks:
	./setup-symlinks.sh validate

check-tracked-ignored:
	@tracked_ignored="$$(git ls-files -ci --exclude-standard)"; \
	if [ -n "$$tracked_ignored" ]; then \
		printf '%s\n' "tracked files ignored by .gitignore (report-only):"; \
		printf '%s\n' "$$tracked_ignored"; \
	else \
		printf '%s\n' "no tracked files are ignored by .gitignore"; \
	fi

install-hooks:
	install -d "$$(dirname "$$(git rev-parse --git-path hooks/pre-commit)")"
	install -m 0755 hooks/pre-commit "$$(git rev-parse --git-path hooks/pre-commit)"

sync-saski-repos:
	./sync-saski-repos.sh

sync-saski-repos-apply:
	./sync-saski-repos.sh --apply

discover-saski-repos:
	./sync-saski-repos.sh --discover

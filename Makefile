.PHONY: check test lint-shell validate-skills validate-symlinks check-tracked-ignored install-hooks

SHELL_SCRIPTS := \
	setup-symlinks.sh \
	sync-skill-factory.sh \
	pull-and-sync-skills.sh \
	backup-cursor-config.sh \
	validate-skill-library.sh \
	tests/validate-skill-library-test.sh \
	tests/healthcheck-automation-test.sh \
	hooks/pre-commit

check: test lint-shell validate-skills validate-symlinks check-tracked-ignored

test:
	./tests/validate-skill-library-test.sh
	./tests/healthcheck-automation-test.sh

lint-shell:
	bash -n $(SHELL_SCRIPTS)

validate-skills:
	./validate-skill-library.sh

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

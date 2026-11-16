ZIRAN ?= ziran
LOCKED := $(if $(wildcard ziran.local.toml),,--locked)
PROJECT = --project $(LOCKED)

.PHONY: test app
# RFC 6238 codes for SHA-1, SHA-256 and SHA-512, RFC 4648 Base32 and the
# authenticator exports, run as portable bundles like the app itself.
test: app
	mkdir -p build
	for name in totp exports; do \
		$(ZIRAN) bundle $(PROJECT) --root . --entry $${name}_test:Run -o build/$$name.zx tests/$${name}_test.zi && \
		test "$$($(ZIRAN) run build/$$name.zx)" = 0 || exit 1; \
	done
	$(ZIRAN) bundle $(PROJECT) --root . --define KRYON_HOSTED_UI --bind-host card_host --entry card_test:Run -o build/card.zx tests/card_test.zi
	test "$$($(ZIRAN) run build/card.zx)" = 0
	@echo 'Auth: RFC 6238 codes, Base32, links and authenticator exports passed'

# The Auth app as a hosted Kryon bundle, as Werkzeug packs it.
app:
	mkdir -p build
	$(ZIRAN) bundle $(PROJECT) --root . --define KRYON_HOSTED_UI --entry auth:Main -o build/auth.zx src/auth.zi

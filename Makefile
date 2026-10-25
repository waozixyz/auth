ZIRAN ?= ziran
LOCKED := $(if $(wildcard ziran.local.toml),,--locked)
STD = $(shell $(ZIRAN) pkg path ziran $(LOCKED))/std
CRYPTO = $(shell $(ZIRAN) pkg path crypto $(LOCKED))
KRYON = $(shell $(ZIRAN) pkg path kryon $(LOCKED))
MINGCUTE = $(shell $(ZIRAN) pkg path mingcute $(LOCKED))
PATHS = --module-path src --module-path crypto=$(CRYPTO)/src --module-path $(STD)

.PHONY: test app
# RFC 6238 codes for SHA-1, SHA-256 and SHA-512, RFC 4648 Base32 and the
# authenticator exports, run as portable bundles like the app itself.
test: app
	mkdir -p build
	for name in totp exports; do \
		$(ZIRAN) bundle --root . $(PATHS) --entry $${name}_test:Run -o build/$$name.zx tests/$${name}_test.zi && \
		test "$$($(ZIRAN) run build/$$name.zx)" = 0 || exit 1; \
	done
	@echo 'Auth: RFC 6238 codes, Base32, links and authenticator exports passed'

# The Auth app as a hosted Kryon bundle, as Werkzeug packs it.
app:
	mkdir -p build
	$(ZIRAN) bundle --root . $(PATHS) --module-path kryon=$(KRYON)/src/backend --module-path kryon=$(KRYON)/src/ui \
		--module-path $(KRYON)/src/ui --module-path $(MINGCUTE)/src --define KRYON_HOSTED_UI --entry auth:Main -o build/auth.zx src/auth.zi

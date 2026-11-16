ZIRAN ?= ziran
LOCKED := $(if $(wildcard ziran.local.toml),,--locked)
STD = $(shell $(ZIRAN) pkg path ziran $(LOCKED))/std
CRYPTO = $(shell $(ZIRAN) pkg path crypto $(LOCKED))
KRYON = $(shell $(ZIRAN) pkg path kryon $(LOCKED))
MINGCUTE = $(shell $(ZIRAN) pkg path mingcute $(LOCKED))
PATHS = --module-path src --module-path crypto=$(CRYPTO)/src --module-path $(STD)
UI_PATHS = --module-path kryon=$(KRYON)/src/backend --module-path kryon=$(KRYON)/src/ui \
	--module-path $(KRYON)/src/ui --module-path $(MINGCUTE)/src --define KRYON_HOSTED_UI

.PHONY: test app
# RFC 6238 codes for SHA-1, SHA-256 and SHA-512, RFC 4648 Base32 and the
# authenticator exports, run as portable bundles like the app itself.
test: app
	mkdir -p build
	for name in totp exports; do \
		$(ZIRAN) bundle --root . $(PATHS) --entry $${name}_test:Run -o build/$$name.zx tests/$${name}_test.zi && \
		test "$$($(ZIRAN) run build/$$name.zx)" = 0 || exit 1; \
	done
	$(ZIRAN) bundle --root . $(PATHS) $(UI_PATHS) --module-path tests --module-path $(KRYON)/src/backend --bind button_widget:ButtonHostedHost=card_host:ButtonHostedHost --bind box_widget:BoxHostedHost=card_host:BoxHostedHost --bind text_widget:TextHostedHost=card_host:TextHostedHost --bind app_context:AppNowHost=card_host:AppNowHost --bind app_context:AppDarkHost=card_host:AppDarkHost --bind app_context:ClipboardCopyHost=card_host:ClipboardCopyHost --entry card_test:Run -o build/card.zx tests/card_test.zi
	test "$$($(ZIRAN) run build/card.zx)" = 0
	@echo 'Auth: RFC 6238 codes, Base32, links and authenticator exports passed'

# The Auth app as a hosted Kryon bundle, as Werkzeug packs it.
app:
	mkdir -p build
	$(ZIRAN) bundle --root . $(PATHS) $(UI_PATHS) --entry auth:Main -o build/auth.zx src/auth.zi

# Auth

Two-factor codes as a Ziran package: time-based one-time passwords (RFC 6238)
with HMAC-SHA-1, SHA-256 or SHA-512, `otpauth://` links, authenticator
exports (Google's `otpauth-migration://`, Ente Auth's plain text, Aegis plain
JSON) and the Auth app's screens for Kryon. The hashes come from
[crypto](https://github.com/ziranlang/crypto).

Werkzeug packs the Auth app and its `werk auth` command from this package.

    make test    # RFC vectors and exports
    make app     # build/auth.zx

Modules: `auth` (the app), `totp` (codes, Base32 and links) and `exports`
(authenticator exports).

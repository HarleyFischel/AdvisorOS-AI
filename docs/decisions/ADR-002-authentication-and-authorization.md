# ADR-002: Server-managed sessions and explicit role authorization

Status: accepted

BCrypt-backed `has_secure_password`, encrypted HttpOnly cookies, SameSite protection, CSRF tokens, and generic login errors avoid exposing bearer tokens to browser storage. Controller role checks and organization-rooted queries enforce authorization server-side.

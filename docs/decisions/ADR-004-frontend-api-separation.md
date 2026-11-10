# ADR-004: Separate React SPA from Rails JSON API

Status: accepted

The React client provides responsive interaction and typed API boundaries while Rails remains the security and data authority. Credential-aware CORS is narrowly configured for the local frontend origin, with no access tokens in localStorage.

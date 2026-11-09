# API documentation

The JSON API is namespaced under `/api/v1`. Authentication uses the session cookie established by `POST /api/v1/session`; clients must first fetch `GET /api/v1/csrf` and send the returned value in `X-CSRF-Token` for state-changing requests. Successful collections return `{ data: [], meta: { page, per_page, total } }`; failures return `{ error: { code, message, details? } }`.

Resources: households, clients, opportunities, and client activities. Dashboard data is available at `/api/v1/dashboard`; `/api/v1/me` returns the current user. Organization scope is always derived from the authenticated session.

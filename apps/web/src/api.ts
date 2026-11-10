const API_URL = import.meta.env.VITE_API_URL ?? "";
let csrfToken = "";

export class ApiError extends Error { constructor(public status: number, message: string, public details?: unknown) { super(message); } }

async function ensureCsrf() { if (csrfToken) return csrfToken; const response = await fetch(`${API_URL}/api/v1/csrf`, { credentials: "include" }); const body = await response.json(); csrfToken = body.csrf_token; return csrfToken; }

export async function api<T>(path: string, options: RequestInit = {}): Promise<T> {
  const method = (options.method ?? "GET").toUpperCase();
  const headers = new Headers(options.headers);
  headers.set("Accept", "application/json");
  if (options.body && !headers.has("Content-Type")) headers.set("Content-Type", "application/json");
  if (!["GET", "HEAD", "OPTIONS"].includes(method)) headers.set("X-CSRF-Token", await ensureCsrf());
  const response = await fetch(`${API_URL}${path}`, { ...options, headers, credentials: "include" });
  if (response.status === 204) return undefined as T;
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new ApiError(response.status, body.error?.message ?? "Something went wrong", body.error?.details);
  if (path === "/api/v1/session" && method === "POST") csrfToken = "";
  return body as T;
}

export const getData = <T>(path: string) => api<{ data: T }>(path).then((body) => body.data);

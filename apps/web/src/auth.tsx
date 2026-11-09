import { createContext, useContext, useEffect, useRef, useState, type ReactNode } from "react";
import { api } from "./api";
import type { User } from "./types";

/* eslint-disable react-refresh/only-export-components */

type AuthContext = { user: User | null; loading: boolean; login: (email: string, password: string) => Promise<void>; logout: () => Promise<void> };
const Context = createContext<AuthContext | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null); const [loading, setLoading] = useState(true); const authRevision = useRef(0);
  useEffect(() => { const revision = authRevision.current; api<{ data: User }>("/api/v1/me").then((body) => { if (revision === authRevision.current) setUser(body.data); }).catch(() => { if (revision === authRevision.current) setUser(null); }).finally(() => { if (revision === authRevision.current) setLoading(false); }); }, []);
  async function login(email: string, password: string) { const body = await api<{ data: { user: User } }>("/api/v1/session", { method: "POST", body: JSON.stringify({ email, password }) }); authRevision.current += 1; setUser(body.data.user); setLoading(false); }
  async function logout() { await api("/api/v1/session", { method: "DELETE" }); authRevision.current += 1; setUser(null); setLoading(false); }
  return <Context.Provider value={{ user, loading, login, logout }}>{children}</Context.Provider>;
}
export function useAuth() { const context = useContext(Context); if (!context) throw new Error("useAuth must be used inside AuthProvider"); return context; }

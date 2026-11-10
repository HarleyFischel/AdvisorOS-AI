import { Component, type ErrorInfo, type ReactNode } from "react";
import { NavLink, Outlet, useNavigate } from "react-router-dom";
import { useAuth } from "./auth";

type ErrorBoundaryProps = { children: ReactNode };
type ErrorBoundaryState = { hasError: boolean };

export class AppErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  state: ErrorBoundaryState = { hasError: false };

  static getDerivedStateFromError(): ErrorBoundaryState { return { hasError: true }; }

  componentDidCatch(error: Error, info: ErrorInfo) { console.error("AdvisorOS UI render error", error, info); }

  render() {
    if (!this.state.hasError) return this.props.children;
    return <main className="error-screen"><div className="panel error-panel"><span className="eyebrow">ADVISOROS CRM</span><h2>We hit a display error.</h2><p>Refresh this workspace to continue. Your saved CRM data is unchanged.</p><button className="primary-button" onClick={() => window.location.reload()}>Refresh workspace</button></div></main>;
  }
}

export function AppShell() {
  const { user, logout } = useAuth(); const navigate = useNavigate();
  const links = [["/", "Overview"], ["/clients", "Clients"], ["/households", "Households"], ["/opportunities", "Pipeline"], ["/assistant", "AI Assistant"], ["/settings", "Settings"]];
  return <div className="app-shell"><aside className="sidebar"><div className="brand"><span className="brand-mark">A</span><span>AdvisorOS <em>AI</em></span></div><nav aria-label="Primary navigation">{links.map(([to, label]) => <NavLink key={to} to={to} end={to === "/"}>{label}</NavLink>)}</nav><div className="sidebar-footer"><small>{user?.organization.name}</small><button className="text-button" onClick={() => { void logout().then(() => navigate("/login")); }}>Sign out</button></div></aside><main className="main-content"><header className="topbar"><div><span className="eyebrow">ADVISOROS CRM</span><h1>Good morning, {user?.full_name.split(" ")[0]}</h1></div><div className="user-chip"><span>{user?.full_name.slice(0, 1)}</span><div><strong>{user?.full_name}</strong><small>{user?.role}</small></div><button className="text-button topbar-signout" onClick={() => { void logout().then(() => navigate("/login")); }}>Sign out</button></div></header><div className="content"><Outlet /></div></main></div>;
}

export function PageHeader({ title, description, action }: { title: string; description?: string; action?: React.ReactNode }) { return <div className="page-header"><div><h2>{title}</h2>{description && <p>{description}</p>}</div>{action}</div>; }
export function StateMessage({ title, message, error = false }: { title: string; message: string; error?: boolean }) { return <div className={`state-message ${error ? "is-error" : ""}`}><strong>{title}</strong><span>{message}</span></div>; }
export function StatCard({ label, value, detail }: { label: string; value: string; detail?: string }) { return <div className="stat-card"><span>{label}</span><strong>{value}</strong>{detail && <small>{detail}</small>}</div>; }

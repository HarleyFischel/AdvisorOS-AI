import { FormEvent, useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { api } from "../api";
import type { Client } from "../types";
import { PageHeader, StateMessage } from "../components";

export function ClientForm() {
  const { id } = useParams(); const navigate = useNavigate(); const editing = Boolean(id);
  const existing = useQuery({ queryKey: ["client", id, "form"], queryFn: () => api<{ data: Client; activities: unknown[] }>(`/api/v1/clients/${id}`), enabled: editing });
  const client = existing.data?.data;
  const [firstName, setFirstName] = useState(""); const [lastName, setLastName] = useState(""); const [email, setEmail] = useState(""); const [phone, setPhone] = useState(""); const [status, setStatus] = useState("prospect"); const [aum, setAum] = useState("0"); const [error, setError] = useState(""); const [initialized, setInitialized] = useState(false);
  useEffect(() => { if (!client || initialized) return; setFirstName(client.first_name); setLastName(client.last_name); setEmail(client.email ?? ""); setPhone(client.phone ?? ""); setStatus(client.status); setAum(client.estimated_aum); setInitialized(true); }, [client, initialized]);
  if (editing && existing.isPending) return <StateMessage title="Loading client" message="Preparing the edit form…" />;
  async function submit(event: FormEvent) { event.preventDefault(); setError(""); try { const body = { first_name: firstName, last_name: lastName, email, phone, status, estimated_aum: aum }; const response = await api<{ data: Client }>(editing ? `/api/v1/clients/${id}` : "/api/v1/clients", { method: editing ? "PATCH" : "POST", body: JSON.stringify(body) }); navigate(`/clients/${response.data.id}`); } catch (err) { setError(err instanceof Error ? err.message : "Unable to save client"); } }
  return <><PageHeader title={editing ? "Edit client" : "Add client"} description="Keep relationship details accurate and organization-scoped." /><form className="panel form-panel" onSubmit={submit}><div className="form-grid"><label>First name<input required value={firstName} onChange={(event) => setFirstName(event.target.value)} /></label><label>Last name<input required value={lastName} onChange={(event) => setLastName(event.target.value)} /></label><label>Email<input type="email" value={email} onChange={(event) => setEmail(event.target.value)} /></label><label>Phone<input value={phone} onChange={(event) => setPhone(event.target.value)} /></label><label>Status<select value={status} onChange={(event) => setStatus(event.target.value)}><option value="prospect">Prospect</option><option value="active">Active</option><option value="inactive">Inactive</option></select></label><label>Estimated AUM<input type="number" min="0" step="0.01" value={aum} onChange={(event) => setAum(event.target.value)} /></label></div>{error && <div className="form-error" role="alert">{error}</div>}<div className="form-actions"><button type="button" className="secondary-button" onClick={() => navigate(-1)}>Cancel</button><button className="primary-button">{editing ? "Save changes" : "Create client"}</button></div></form></>;
}

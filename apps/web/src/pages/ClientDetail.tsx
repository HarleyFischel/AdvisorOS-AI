import { FormEvent, useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { Link, useNavigate, useParams } from "react-router-dom";
import { api } from "../api";
import { useAuth } from "../auth";
import type { Client, Activity } from "../types";
import { PageHeader, StateMessage } from "../components";

const localDateTime = () => new Date().toISOString().slice(0, 16);

export function ClientDetail() {
  const navigate = useNavigate();
  const { id } = useParams();
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const [activityType, setActivityType] = useState("note");
  const [summary, setSummary] = useState("");
  const [occurredAt, setOccurredAt] = useState(localDateTime);
  const [activityError, setActivityError] = useState("");
  const [activityOpen, setActivityOpen] = useState(false);
  const [deleteError, setDeleteError] = useState("");
  const query = useQuery({ queryKey: ["client", id], queryFn: () => api<{ data: Client; activities: Activity[] }>(`/api/v1/clients/${id}`) });
  const canManage = user?.role === "admin" || user?.role === "advisor";

  if (query.isPending) return <StateMessage title="Loading client" message="Opening the relationship profile…" />;
  if (query.isError) return <StateMessage error title="Client unavailable" message={query.error.message} />;
  const { data: client, activities } = query.data;

  async function createActivity(event: FormEvent) {
    event.preventDefault();
    setActivityError("");
    try {
      await api(`/api/v1/clients/${client.id}/activities`, { method: "POST", body: JSON.stringify({ activity_type: activityType, summary, occurred_at: new Date(occurredAt).toISOString() }) });
      setSummary("");
      setActivityOpen(false);
      await queryClient.invalidateQueries({ queryKey: ["client", id] });
    } catch (err) {
      setActivityError(err instanceof Error ? err.message : "Unable to log activity");
    }
  }

  async function removeClient() {
    if (!window.confirm(`Delete ${client.full_name}? Clients with activities or opportunities cannot be deleted.`)) return;
    setDeleteError("");
    try {
      await api(`/api/v1/clients/${client.id}`, { method: "DELETE" });
      navigate("/clients");
    } catch (err) {
      setDeleteError(err instanceof Error ? err.message : "Unable to delete client");
    }
  }

  return <><Link className="back-link" to="/clients">← Back to clients</Link><PageHeader title={client.full_name} description={`${client.status} relationship · ${client.household?.name ?? "No household"}`} action={canManage ? <div className="header-actions"><button className="secondary-button" onClick={() => navigate(`/clients/${client.id}/edit`)}>Edit profile</button><button className="danger-button" onClick={() => void removeClient()}>Delete client</button></div> : undefined} />
    {deleteError && <div className="form-error mutation-error" role="alert">{deleteError}</div>}
    <div className="detail-grid"><section className="panel profile-card"><span className="avatar-large">{client.first_name[0]}{client.last_name[0]}</span><h3>Relationship details</h3><dl><div><dt>Email</dt><dd>{client.email ?? "—"}</dd></div><div><dt>Phone</dt><dd>{client.phone ?? "—"}</dd></div><div><dt>Assigned advisor</dt><dd>{client.assigned_user?.full_name ?? "—"}</dd></div><div><dt>Estimated AUM</dt><dd>{new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(Number(client.estimated_aum))}</dd></div></dl></section><section className="panel"><div className="panel-heading"><div><span className="eyebrow">TIMELINE</span><h3>Activity history</h3></div>{canManage && <button className="secondary-button" onClick={() => setActivityOpen((value) => !value)}>＋ Log activity</button>}</div>
      {activityOpen && <form className="activity-form" onSubmit={createActivity}><label>Type<select value={activityType} onChange={(event) => setActivityType(event.target.value)}><option value="note">Note</option><option value="call">Call</option><option value="email">Email</option><option value="meeting">Meeting</option><option value="task">Task</option></select></label><label>Summary<textarea required maxLength={2000} value={summary} onChange={(event) => setSummary(event.target.value)} /></label><label>Occurred at<input required type="datetime-local" value={occurredAt} onChange={(event) => setOccurredAt(event.target.value)} /></label>{activityError && <div className="form-error" role="alert">{activityError}</div>}<div className="form-actions"><button type="button" className="secondary-button" onClick={() => setActivityOpen(false)}>Cancel</button><button className="primary-button">Save activity</button></div></form>}
      <div className="activity-list timeline">{activities.length ? activities.map((activity) => <div className="activity-item" key={activity.id}><span className="activity-dot" /><div><strong>{activity.summary}</strong><small>{activity.activity_type} · {activity.user.full_name} · {new Date(activity.occurred_at).toLocaleString()}</small></div></div>) : <StateMessage title="No activity yet" message="Log the first touchpoint for this relationship." />}</div></section></div></>;
}

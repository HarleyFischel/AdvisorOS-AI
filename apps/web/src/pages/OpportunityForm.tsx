import { FormEvent, useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { api } from "../api";
import { useAuth } from "../auth";
import type { Client, Opportunity } from "../types";
import { PageHeader, StateMessage } from "../components";

const stages = ["lead", "qualified", "proposal", "negotiation", "won", "lost"];
type ClientResponse = { data: Client[]; meta: { page: number; per_page: number; total: number } };

export function OpportunityForm() {
  const { id } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { user } = useAuth();
  const editing = Boolean(id);
  const existing = useQuery({
    queryKey: ["opportunity", id, "form"],
    queryFn: () => api<{ data: Opportunity }>(`/api/v1/opportunities/${id}`),
    enabled: editing,
  });
  const clients = useQuery({ queryKey: ["clients", "opportunity-form"], queryFn: () => api<ClientResponse>("/api/v1/clients?per_page=100&sort=last_name") });
  const opportunity = existing.data?.data;
  const [title, setTitle] = useState("");
  const [clientId, setClientId] = useState("");
  const [stage, setStage] = useState("lead");
  const [estimatedValue, setEstimatedValue] = useState("0");
  const [expectedCloseDate, setExpectedCloseDate] = useState("");
  const [error, setError] = useState("");
  const [initialized, setInitialized] = useState(false);

  useEffect(() => {
    if (!opportunity || initialized) return;
    setTitle(opportunity.title);
    setClientId(opportunity.client.id);
    setStage(opportunity.stage);
    setEstimatedValue(opportunity.estimated_value);
    setExpectedCloseDate(opportunity.expected_close_date ?? "");
    setInitialized(true);
  }, [opportunity, initialized]);

  if ((editing && existing.isPending) || clients.isPending) return <StateMessage title="Loading opportunity" message="Preparing the pipeline form…" />;
  if ((editing && existing.isError) || clients.isError) return <StateMessage error title="Opportunity form unavailable" message={(existing.error ?? clients.error)?.message ?? "Unable to load form data"} />;

  async function submit(event: FormEvent) {
    event.preventDefault();
    setError("");
    try {
      await api<{ data: Opportunity }>(editing ? `/api/v1/opportunities/${id}` : "/api/v1/opportunities", {
        method: editing ? "PATCH" : "POST",
        body: JSON.stringify({ client_id: clientId, owner_user_id: user?.id, title, stage, estimated_value: estimatedValue, expected_close_date: expectedCloseDate || null }),
      });
      await queryClient.invalidateQueries({ queryKey: ["opportunities"] });
      navigate("/opportunities", { state: { notice: editing ? "Opportunity updated" : "Opportunity created" } });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to save opportunity");
    }
  }

  return <>
    <PageHeader title={editing ? "Edit opportunity" : "Add opportunity"} description="Track a permissioned, organization-scoped growth opportunity." />
    <form className="panel form-panel" onSubmit={submit}>
      <div className="form-grid">
        <label>Title<input required maxLength={180} value={title} onChange={(event) => setTitle(event.target.value)} /></label>
        <label>Client<select required value={clientId} onChange={(event) => setClientId(event.target.value)}><option value="">Choose a client</option>{clients.data.data.map((client) => <option key={client.id} value={client.id}>{client.full_name}</option>)}</select></label>
        <label>Stage<select value={stage} onChange={(event) => setStage(event.target.value)}>{stages.map((option) => <option key={option} value={option}>{option}</option>)}</select></label>
        <label>Estimated value<input required type="number" min="0" step="0.01" value={estimatedValue} onChange={(event) => setEstimatedValue(event.target.value)} /></label>
        <label>Expected close date<input type="date" value={expectedCloseDate} onChange={(event) => setExpectedCloseDate(event.target.value)} /></label>
        <label>Owner<input value={user?.full_name ?? ""} readOnly aria-describedby="owner-help" /><small id="owner-help" className="field-help">The current signed-in advisor owns newly created opportunities.</small></label>
      </div>
      {error && <div className="form-error" role="alert">{error}</div>}
      <div className="form-actions"><button type="button" className="secondary-button" onClick={() => navigate(-1)}>Cancel</button><button className="primary-button">{editing ? "Save changes" : "Create opportunity"}</button></div>
    </form>
  </>;
}

import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { getData, api } from "../api";
import { useAuth } from "../auth";
import type { Opportunity } from "../types";
import { PageHeader, StateMessage } from "../components";
const stages = ["lead", "qualified", "proposal", "negotiation", "won", "lost"];
const currency = (value: string) => new Intl.NumberFormat("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 }).format(Number(value));
export function Opportunities() {
  const client = useQueryClient();
  const navigate = useNavigate();
  const { user } = useAuth();
  const [error, setError] = useState("");
  const query = useQuery({ queryKey: ["opportunities"], queryFn: () => getData<Opportunity[]>("/api/v1/opportunities?per_page=100") });
  const canManage = user?.role === "admin" || user?.role === "advisor";

  if (query.isPending) return <StateMessage title="Loading pipeline" message="Assembling your opportunity flow…" />;
  if (query.isError) return <StateMessage error title="Could not load pipeline" message={query.error.message} />;

  async function changeStage(opportunity: Opportunity, stage: string) {
    setError("");
    try {
      await api(`/api/v1/opportunities/${opportunity.id}`, { method: "PATCH", body: JSON.stringify({ stage }) });
      await client.invalidateQueries({ queryKey: ["opportunities"] });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to update opportunity");
    }
  }

  async function remove(opportunity: Opportunity) {
    if (!window.confirm(`Delete ${opportunity.title}? This cannot be undone.`)) return;
    setError("");
    try {
      await api(`/api/v1/opportunities/${opportunity.id}`, { method: "DELETE" });
      await client.invalidateQueries({ queryKey: ["opportunities"] });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to delete opportunity");
    }
  }

  return <>
    <PageHeader title="Pipeline" description="Move opportunities forward with a shared view of growth." action={canManage ? <button className="primary-button" onClick={() => navigate("/opportunities/new")}>＋ New opportunity</button> : undefined} />
    {error && <div className="form-error mutation-error" role="alert">{error}</div>}
    <div className="pipeline-board">{stages.map((stage) => <section className="pipeline-column" key={stage}><div className="column-title"><span>{stage}</span><b>{query.data.filter((opportunity) => opportunity.stage === stage).length}</b></div>{query.data.filter((opportunity) => opportunity.stage === stage).map((opportunity) => <article className="opportunity-card" key={opportunity.id}>
      <strong>{opportunity.title}</strong><span>{opportunity.client.full_name}</span>
      <div><b>{currency(opportunity.estimated_value)}</b><select disabled={!canManage} aria-label={`Move ${opportunity.title}`} value={opportunity.stage} onChange={(event) => void changeStage(opportunity, event.target.value)}>{stages.map((option) => <option key={option}>{option}</option>)}</select></div>
      {canManage && <div className="card-actions"><button className="text-button" onClick={() => navigate(`/opportunities/${opportunity.id}/edit`)}>Edit</button><button className="text-button danger-text" onClick={() => void remove(opportunity)}>Delete</button></div>}
    </article>)}</section>)}</div>
  </>;
}

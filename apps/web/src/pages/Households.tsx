import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { api, getData } from "../api";
import { useAuth } from "../auth";
import type { Household } from "../types";
import { PageHeader, StateMessage } from "../components";
export function Households() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { user } = useAuth();
  const [error, setError] = useState("");
  const query = useQuery({ queryKey: ["households"], queryFn: () => getData<Household[]>("/api/v1/households") });
  const canManage = user?.role === "admin" || user?.role === "advisor";

  async function remove(household: Household) {
    if (!window.confirm(`Delete ${household.name}? Households with clients cannot be deleted.`)) return;
    setError("");
    try {
      await api(`/api/v1/households/${household.id}`, { method: "DELETE" });
      await queryClient.invalidateQueries({ queryKey: ["households"] });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to delete household");
    }
  }

  if (query.isPending) return <StateMessage title="Loading households" message="Preparing planning relationships…" />;
  if (query.isError) return <StateMessage error title="Could not load households" message={query.error.message} />;

  return <>
    <PageHeader title="Households" description="The planning context behind each client relationship." action={canManage ? <button className="primary-button" onClick={() => navigate("/households/new")}>＋ New household</button> : undefined} />
    {error && <div className="form-error mutation-error" role="alert">{error}</div>}
    {query.data.length ? <div className="card-grid">{query.data.map((household) => <article className="panel household-card" key={household.id}>
      <div className="household-icon">⌂</div>
      <div><h3>{household.name}</h3><p>{household.description || "No description provided."}</p><small>{household.client_count} clients</small></div>
      {canManage && <div className="card-actions"><button className="icon-button" onClick={() => navigate(`/households/${household.id}/edit`)} aria-label={`Edit ${household.name}`}>Edit</button><button className="icon-button danger-button" onClick={() => void remove(household)} aria-label={`Delete ${household.name}`}>Delete</button></div>}
    </article>)}</div> : <StateMessage title="No households yet" message="Create a household to organize related client relationships." />}
  </>;
}

import { FormEvent, useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { api } from "../api";
import type { Household } from "../types";
import { PageHeader, StateMessage } from "../components";

export function HouseholdForm() {
  const { id } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const editing = Boolean(id);
  const existing = useQuery({
    queryKey: ["household", id, "form"],
    queryFn: () => api<{ data: Household }>(`/api/v1/households/${id}`),
    enabled: editing,
  });
  const household = existing.data?.data;
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [error, setError] = useState("");
  const [initialized, setInitialized] = useState(false);

  useEffect(() => {
    if (!household || initialized) return;
    setName(household.name);
    setDescription(household.description ?? "");
    setInitialized(true);
  }, [household, initialized]);

  if (editing && existing.isPending) return <StateMessage title="Loading household" message="Preparing the edit form…" />;
  if (editing && existing.isError) return <StateMessage error title="Household unavailable" message={existing.error.message} />;

  async function submit(event: FormEvent) {
    event.preventDefault();
    setError("");
    try {
      await api<{ data: Household }>(editing ? `/api/v1/households/${id}` : "/api/v1/households", {
        method: editing ? "PATCH" : "POST",
        body: JSON.stringify({ name, description }),
      });
      await queryClient.invalidateQueries({ queryKey: ["households"] });
      navigate("/households", { state: { notice: editing ? "Household updated" : "Household created" } });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unable to save household");
    }
  }

  return <>
    <PageHeader title={editing ? "Edit household" : "Add household"} description="Keep planning relationships organized for your advisory team." />
    <form className="panel form-panel" onSubmit={submit}>
      <div className="form-grid">
        <label>Name<input required maxLength={160} value={name} onChange={(event) => setName(event.target.value)} /></label>
        <label>Description<textarea rows={4} maxLength={2000} value={description} onChange={(event) => setDescription(event.target.value)} /></label>
      </div>
      {error && <div className="form-error" role="alert">{error}</div>}
      <div className="form-actions"><button type="button" className="secondary-button" onClick={() => navigate(-1)}>Cancel</button><button className="primary-button">{editing ? "Save changes" : "Create household"}</button></div>
    </form>
  </>;
}

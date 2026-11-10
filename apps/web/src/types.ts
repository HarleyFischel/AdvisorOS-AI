export type Role = "admin" | "advisor" | "viewer";
export type User = { id: string; email: string; full_name: string; role: Role; organization: { id: string; name: string } };
export type Client = { id: string; first_name: string; last_name: string; full_name: string; email?: string; phone?: string; status: string; estimated_aum: string; household?: { id: string; name: string }; assigned_user?: { id: string; full_name: string } };
export type Household = { id: string; name: string; description?: string; client_count: number };
export type Opportunity = { id: string; title: string; stage: string; estimated_value: string; expected_close_date?: string; client: { id: string; full_name: string }; owner: { id: string; full_name: string } };
export type Activity = { id: string; activity_type: string; summary: string; occurred_at: string; user: { full_name: string }; client: { id: string; full_name: string } };
export type Dashboard = { metrics: { total_clients: number; total_households: number; total_estimated_aum: string; open_opportunities: number }; pipeline_by_stage: Record<string, { count: number; value: string }>; recent_activities: Activity[]; client_growth: { month: string; count: number }[] };

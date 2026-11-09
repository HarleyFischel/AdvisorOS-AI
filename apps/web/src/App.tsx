import { Navigate, Route, Routes } from "react-router-dom";
import { useAuth } from "./auth";
import { AppShell } from "./components";
import { Login } from "./pages/Login";
import { Dashboard } from "./pages/Dashboard";
import { Clients } from "./pages/Clients";
import { ClientDetail } from "./pages/ClientDetail";
import { ClientForm } from "./pages/ClientForm";
import { Households } from "./pages/Households";
import { Opportunities } from "./pages/Opportunities";
import { Assistant, Settings } from "./pages/Utility";

function Protected() { const { user, loading } = useAuth(); if (loading) return <div className="loading-screen">Loading AdvisorOS…</div>; return user ? <AppShell /> : <Navigate to="/login" replace />; }
export function App() { return <Routes><Route path="/login" element={<Login />} /><Route element={<Protected />}><Route path="/" element={<Dashboard />} /><Route path="/clients" element={<Clients />} /><Route path="/clients/new" element={<ClientForm />} /><Route path="/clients/:id/edit" element={<ClientForm />} /><Route path="/clients/:id" element={<ClientDetail />} /><Route path="/households" element={<Households />} /><Route path="/opportunities" element={<Opportunities />} /><Route path="/assistant" element={<Assistant />} /><Route path="/settings" element={<Settings />} /></Route><Route path="*" element={<Navigate to="/" replace />} /></Routes>; }

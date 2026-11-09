import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { AuthProvider } from "./auth";
import { App } from "./App";
import { AppErrorBoundary } from "./components";
import { ThemeProvider } from "./theme";
import "./styles.css";

const client = new QueryClient({ defaultOptions: { queries: { staleTime: 15_000, retry: 1 } } });
createRoot(document.getElementById("root")!).render(<StrictMode><ThemeProvider><AppErrorBoundary><QueryClientProvider client={client}><BrowserRouter><AuthProvider><App /></AuthProvider></BrowserRouter></QueryClientProvider></AppErrorBoundary></ThemeProvider></StrictMode>);

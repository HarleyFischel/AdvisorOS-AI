import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import { StatCard } from "./components";

describe("StatCard", () => {
  it("renders accessible metric labels and values", () => {
    render(<StatCard label="Total clients" value="30" detail="Across your organization" />);
    expect(screen.getByText("Total clients")).toBeInTheDocument();
    expect(screen.getByText("30")).toBeInTheDocument();
  });
});

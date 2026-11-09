import { fireEvent, render, screen } from "@testing-library/react";
import { beforeEach, describe, expect, it } from "vitest";
import { ThemeProvider, useTheme } from "./theme";

function ThemeProbe() {
  const { theme, resolvedTheme, setTheme } = useTheme();
  return <><span data-testid="preference">{theme}</span><span data-testid="resolved">{resolvedTheme}</span><button onClick={() => setTheme("light")}>Light</button></>;
}

describe("ThemeProvider", () => {
  beforeEach(() => { window.localStorage.clear(); document.documentElement.removeAttribute("data-theme"); });

  it("defaults to system and persists an explicit theme choice", () => {
    render(<ThemeProvider><ThemeProbe /></ThemeProvider>);
    expect(screen.getByTestId("preference")).toHaveTextContent("system");
    fireEvent.click(screen.getByRole("button", { name: "Light" }));
    expect(screen.getByTestId("preference")).toHaveTextContent("light");
    expect(screen.getByTestId("resolved")).toHaveTextContent("light");
    expect(document.documentElement.dataset.theme).toBe("light");
    expect(window.localStorage.getItem("advisoros-theme")).toBe("light");
  });
});

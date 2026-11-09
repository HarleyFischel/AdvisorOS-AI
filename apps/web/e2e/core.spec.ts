import { test, expect } from "@playwright/test";

test.describe("CRM core journey", () => {
  test("login, browse CRM routes, and logout", async ({ page }) => {
    await page.goto("/login");
    await page.getByLabel("Email").fill("admin@northstar.demo");
    await page.getByLabel("Password").fill("DemoPass!2026");
    await page.getByRole("button", { name: "Continue to workspace" }).click();
    await expect(page.getByRole("heading", { name: "Overview" })).toBeVisible();
    await page.getByRole("link", { name: "Clients" }).click();
    await expect(page.getByRole("heading", { name: "Clients" })).toBeVisible();
    await expect(page.getByRole("table")).toBeVisible();
    await page.getByRole("link", { name: "Alex Demo1", exact: true }).click();
    await expect(page.getByRole("heading", { name: "Alex Demo1" })).toBeVisible();
    await page.getByRole("link", { name: /Back to clients/ }).click();
    await page.getByRole("link", { name: "Households" }).click();
    await expect(page.getByRole("heading", { name: "Households" })).toBeVisible();
    await page.getByRole("link", { name: "Pipeline" }).click();
    await expect(page.getByRole("heading", { name: "Pipeline" })).toBeVisible();
    await page.getByRole("link", { name: "Settings" }).click();
    await expect(page.getByRole("heading", { name: "Settings" })).toBeVisible();
    const theme = page.getByLabel("Color theme");
    await expect(theme).toHaveValue("system");
    await theme.selectOption("light");
    await expect(page.locator("html")).toHaveAttribute("data-theme", "light");
    await theme.selectOption("dark");
    await expect(page.locator("html")).toHaveAttribute("data-theme", "dark");
    await theme.selectOption("system");
    await page.locator(".sidebar-footer .text-button").click({ force: true });
    await expect(page).toHaveURL(/login/);
  });
});

import { test, expect } from "@playwright/test";

test.describe("CRM core journey", () => {
  test("login, view clients, and logout", async ({ page }) => {
    await page.goto("/login");
    await page.getByLabel("Email").fill("admin@northstar.demo");
    await page.getByLabel("Password").fill("DemoPass!2026");
    await page.getByRole("button", { name: "Continue to workspace" }).click();
    await expect(page.getByRole("heading", { name: "Overview" })).toBeVisible();
    await page.getByRole("link", { name: "Clients" }).click();
    await expect(page.getByRole("heading", { name: "Clients" })).toBeVisible();
    await page.locator(".sidebar-footer .text-button").click({ force: true });
    await expect(page).toHaveURL(/login/);
  });
});

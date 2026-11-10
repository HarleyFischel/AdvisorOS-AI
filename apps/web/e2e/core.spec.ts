import { test, expect, type Page } from "@playwright/test";

async function login(page: Page, email: string) {
  await page.goto("/login");
  await page.getByLabel("Email").fill(email);
  await page.getByLabel("Password").fill("DemoPass!2026");
  await page.getByRole("button", { name: "Continue to workspace" }).click();
  await expect(page.getByRole("heading", { name: "Overview" })).toBeVisible();
}

test.describe("CRM core journey", () => {
  test("admin can create, edit, use, and safely delete CRM records", async ({ page }) => {
    const suffix = Date.now().toString();
    const clientName = `Journey Client ${suffix}`;
    const clientEditedName = `Journey Edited ${suffix}`;
    const householdName = `Journey Household ${suffix}`;
    const householdEditedName = `Journey Household Edited ${suffix}`;
    const opportunityName = `Journey Opportunity ${suffix}`;

    await login(page, "admin@northstar.demo");

    await page.getByRole("link", { name: "Clients" }).click();
    await expect(page.getByRole("heading", { name: "Clients" })).toBeVisible();
    await page.getByRole("button", { name: /Add client/ }).click();
    await page.getByLabel("First name").fill("Journey");
    await page.getByLabel("Last name").fill(`Client ${suffix}`);
    await page.getByLabel("Email").fill(`journey-${suffix}@demo.invalid`);
    await page.getByLabel("Estimated AUM").fill("250000");
    await page.getByRole("button", { name: "Create client" }).click();
    await expect(page.getByRole("heading", { name: clientName })).toBeVisible();

    await page.getByRole("button", { name: "Edit profile" }).click();
    await page.getByLabel("Last name").fill(`Edited ${suffix}`);
    await page.getByRole("button", { name: "Save changes" }).click();
    await expect(page.getByRole("heading", { name: clientEditedName })).toBeVisible();
    await page.getByRole("button", { name: /Log activity/ }).click();
    await page.getByLabel("Summary").fill("Completed acceptance journey review");
    await page.getByRole("button", { name: "Save activity" }).click();
    await expect(page.getByText("Completed acceptance journey review")).toBeVisible();
    page.once("dialog", (dialog) => dialog.accept());
    await page.getByRole("button", { name: "Delete client" }).click();
    await expect(page.getByRole("alert")).toContainText("Clients with opportunities or activities cannot be deleted");

    await page.getByRole("link", { name: "Households" }).click();
    await expect(page.getByRole("heading", { name: "Households" })).toBeVisible();
    await page.getByRole("button", { name: /New household/ }).click();
    await page.getByLabel("Name").fill(householdName);
    await page.getByLabel("Description").fill("Acceptance household");
    await page.getByRole("button", { name: "Create household" }).click();
    const householdCard = page.getByRole("article").filter({ hasText: householdName });
    await expect(householdCard).toBeVisible();
    await householdCard.getByRole("button", { name: `Edit ${householdName}` }).click();
    await page.getByLabel("Name").fill(householdEditedName);
    await page.getByRole("button", { name: "Save changes" }).click();
    const editedHouseholdCard = page.getByRole("article").filter({ hasText: householdEditedName });
    await expect(editedHouseholdCard).toBeVisible();
    page.once("dialog", (dialog) => dialog.accept());
    await editedHouseholdCard.getByRole("button", { name: `Delete ${householdEditedName}` }).click();
    await expect(page.getByRole("article").filter({ hasText: householdEditedName })).toHaveCount(0);

    await page.getByRole("link", { name: "Pipeline" }).click();
    await expect(page.getByRole("heading", { name: "Pipeline" })).toBeVisible();
    await page.getByRole("button", { name: /New opportunity/ }).click();
    await page.getByLabel("Title").fill(opportunityName);
    await page.getByLabel("Client").selectOption({ index: 1 });
    await page.getByLabel("Estimated value").fill("125000");
    await page.getByRole("button", { name: "Create opportunity" }).click();
    const opportunityCard = page.getByRole("article").filter({ hasText: opportunityName });
    await expect(opportunityCard).toBeVisible();
    await page.getByLabel(`Move ${opportunityName}`).selectOption("qualified");
    await expect(page.getByLabel(`Move ${opportunityName}`)).toHaveValue("qualified");
    await page.getByLabel(`Move ${opportunityName}`).locator("xpath=ancestor::article").getByRole("button", { name: "Edit" }).click();
    await page.getByLabel("Title").fill(`${opportunityName} Edited`);
    await page.getByRole("button", { name: "Save changes" }).click();
    const editedOpportunityCard = page.getByRole("article").filter({ hasText: `${opportunityName} Edited` });
    await expect(editedOpportunityCard).toBeVisible();
    page.once("dialog", (dialog) => dialog.accept());
    await editedOpportunityCard.getByRole("button", { name: "Delete" }).click();
    await expect(page.getByRole("article").filter({ hasText: `${opportunityName} Edited` })).toHaveCount(0);
  });

  test("viewer restrictions, themes, and logout remain functional", async ({ page }) => {
    await login(page, "viewer@northstar.demo");
    await page.getByRole("link", { name: "Clients" }).click();
    await expect(page.getByRole("heading", { name: "Clients" })).toBeVisible();
    await expect(page.getByRole("button", { name: /Add client/ })).toHaveCount(0);
    await page.getByRole("link", { name: "Households" }).click();
    await expect(page.getByRole("button", { name: /New household/ })).toHaveCount(0);
    await page.getByRole("link", { name: "Pipeline" }).click();
    await expect(page.getByRole("button", { name: /New opportunity/ })).toHaveCount(0);
    await expect(page.locator("select[aria-label^='Move']").first()).toBeDisabled();
    await page.getByRole("link", { name: "Settings" }).click();
    await expect(page.getByRole("heading", { name: "Settings" })).toBeVisible();
    const theme = page.getByLabel("Color theme");
    await expect(theme).toHaveValue("system");
    await theme.selectOption("light");
    await expect(page.locator("html")).toHaveAttribute("data-theme", "light");
    await theme.selectOption("dark");
    await expect(page.locator("html")).toHaveAttribute("data-theme", "dark");
    await theme.selectOption("system");
    await page.getByRole("button", { name: "Sign out" }).last().click();
    await expect(page).toHaveURL(/login/);
  });
});

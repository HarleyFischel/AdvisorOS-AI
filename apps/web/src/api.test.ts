import { describe, expect, it } from "vitest";
import { ApiError } from "./api";

describe("ApiError", () => {
  it("preserves safe status and message for form feedback", () => {
    const error = new ApiError(422, "Validation failed", { email: ["is invalid"] });
    expect(error.status).toBe(422); expect(error.message).toBe("Validation failed"); expect(error.details).toEqual({ email: ["is invalid"] });
  });
});

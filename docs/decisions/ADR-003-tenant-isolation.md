# ADR-003: Organization is the tenancy boundary

Status: accepted

Every business record stores an organization foreign key and has tenant-oriented indexes. Reads start from the current user's organization, and model validations verify associated records share that organization. Conservative delete policies preserve CRM history.

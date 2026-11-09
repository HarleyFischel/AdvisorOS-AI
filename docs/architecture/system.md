# AdvisorOS AI system architecture

## Components

The system is a modular monolith: Rails 7.2 owns authentication, tenant-scoped domain logic, JSON APIs, validation, audit events, and future background jobs. React/Vite is a separate browser client that communicates through the API. PostgreSQL is the system of record. Docker Compose provides local development only.

## Data flow and tenant boundaries

The browser obtains a CSRF token, submits credentials to the Rails session endpoint, and receives a server-managed encrypted session cookie. Each authenticated request resolves a user and organization from the session. Business queries begin from `current_user.organization` and association validators reject household, client, and user IDs from other organizations. Organizations also have database foreign keys, constraints, and tenant query indexes. A second seeded organization is intentionally isolated for tests.

## Authentication and authorization

`has_secure_password` stores BCrypt digests. Login errors are deliberately generic and rate-limited in-process. HttpOnly, SameSite cookies avoid localStorage token risk. CSRF protection is required for state changes. Admins manage all organization records, advisors manage authorized CRM records, and viewers have read-only access. The frontend mirrors this model for usability but is never the security boundary.

## Future AI integration

Mission 001 exposes no live provider calls. The planned interface is a provider-neutral `Ai::Provider` with an `Ai::ToolRegistry`, authorized read tools, proposed action objects, explicit human approval, and an execution audit event. AI jobs should run asynchronously, re-check authorization at execution time, and never receive passwords, session cookies, or unneeded tenant data.

## Future AWS deployment

The planned topology uses EC2 for Rails behind HTTPS, a VPC with private subnets/security groups, private PostgreSQL, S3 for documents, Lambda for event processing, IAM least privilege, Secrets Manager, centralized logs/metrics, backups, health checks, and rollback. Terraform is the primary IaC choice. CloudFormation and Ansible directories are reserved for an isolated later-mission example and provisioning playbooks. No cloud resources are created by Mission 001.

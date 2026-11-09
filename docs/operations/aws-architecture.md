# AWS preparation (not deployed)

Mission 001 creates no AWS resources. The later deployment should validate a Terraform-primary design with a VPC, private PostgreSQL, EC2 Rails nodes behind an HTTPS load balancer, S3 document storage, Lambda event processing, least-privilege IAM, Secrets Manager, centralized logging/metrics, encrypted backups, and an explicit rollback strategy. CloudFormation should be retained as an isolated comparison example, and Ansible should provision a hardened non-root Linux runtime. Every environment must use separate accounts/configuration and no demo credentials.

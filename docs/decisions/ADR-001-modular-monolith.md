# ADR-001: Use a modular monolith

Status: accepted

Rails and React are kept as two deployable application surfaces while domain ownership remains in one Rails process and one relational database. This keeps tenant and authorization rules easy to audit and is appropriate for a portfolio foundation before operational scale justifies service extraction.

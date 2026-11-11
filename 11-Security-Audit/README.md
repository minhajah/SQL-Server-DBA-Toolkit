# 11 – Security Audit

Run server scripts from `master`; run database scripts in each database in scope. Inventories logins, server role membership, explicit server permissions, database users/roles, database permissions, and audit configuration. This is an inventory, not a compliance verdict. Fixed server roles can confer permissions beyond explicit grants. Metadata visibility is permission-dependent. Do not remove principals or permissions without owner validation and change approval. Treat output as sensitive.

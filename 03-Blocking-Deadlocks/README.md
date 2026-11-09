# 03 - Blocking & Deadlocks

## Purpose
Capture live blocking chains, identify head blockers, inspect open transactions, and review recent deadlock evidence retained by the `system_health` Extended Events ring buffer.

## Scripts
- `sql/01_Blocking_Snapshot.sql`
- `sql/02_Deadlock_System_Health_Ring_Buffer.sql`

## Execution
Run `01_Blocking_Snapshot.sql` while users are affected. Repeat at 15-30 second intervals only as needed during a live incident; point-in-time queries can miss short blocking.
Run the deadlock query when a deadlock is reported.

## Interpretation
- A positive `blocking_session_id` means the request is currently blocked by that session.
- A head blocker is a session blocking others but not itself blocked. It may be sleeping with an open transaction, so inspect sessions and transactions as well as active requests.
- Do not kill a session based only on this output. Identify the application owner, transaction scope and rollback impact.
- The ring buffer is finite and can overwrite old events. This query is not durable deadlock history. For reliable history, use a reviewed Extended Events event-file session with controlled retention.

## Safety
Read-only. No session termination, XE configuration change or data cleanup.

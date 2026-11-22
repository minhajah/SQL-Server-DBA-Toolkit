# 14 – Extended Events Analysis

## Purpose
Use SQL Server Management Studio (SSMS) to inspect existing Extended Events (XE) sessions, event targets, deadlock evidence, and captured events **without changing production configuration**.

## Scripts

| File | Purpose | Run from |
|---|---|---|
| `sql/01_Extended_Events_Session_Inventory.sql` | Configured sessions, events, and targets; running state | `master` |
| `sql/02_Extended_Events_Target_Status.sql` | Running targets, event-file paths, and dropped-event counters | `master` |
| `sql/03_Deadlock_System_Health_Event_File.sql` | Recent deadlocks in the existing `system_health` event files | `master` |
| `sql/04_Extended_Events_Event_File_Reader.sql` | Read events from an approved, existing XE event-file target | `master` |

## SSMS investigation procedure

1. **Identify the incident.** Record instance, incident time (including time zone), affected application/database, and symptoms (deadlocks, blocking, timeout, or errors).
2. **Run `01_Extended_Events_Session_Inventory.sql`.** Confirm which sessions are configured and which are running. The presence of a session does not mean it captures the event you need.
3. **Run `02_Extended_Events_Target_Status.sql`.** Check whether the relevant session has an event-file target, its configured path, and whether any events were dropped. An XE ring buffer is finite and can lose older events.
4. **For deadlocks, run `03_Deadlock_System_Health_Event_File.sql`.** Inspect the deadlock XML and note victim process, involved statements, locks, resources, and execution context. Use the XML deadlock graph in SSMS when available. This query uses the existing `system_health` event-file target, if accessible.
5. **For other captured events, run `04_Extended_Events_Event_File_Reader.sql`.** Set the file wildcard to an **existing, approved** XE event-file path, set the optional event name and UTC time window, then execute. It does not create or start an XE session.
6. **Correlate with other modules.** Use `03-Blocking-Deadlocks`, `02-Performance-Analysis`, `05-AlwaysOn-AG`, or `13-Query-Store-Analysis` as relevant. Captured events are evidence, not automatically root cause.
7. **Document findings.** Record event timestamp in UTC, session name, event name, XML evidence, observed impact, and any gaps in collection. Protect sensitive query text, logins, and hostnames.

## Interpreting findings

| Finding | Meaning / next step |
|---|---|
| Deadlock XML | Inspect victim and participating sessions, lock order, transaction scope, and execution plans; do not assume the victim caused the deadlock |
| Missing events | Confirm the session captures the event, target retention, time window, path, and permissions |
| Dropped events | Collection may be incomplete; investigate session overhead and target settings through change control |
| Blocking report absent | `blocked_process_report` is not collected unless a suitable XE session and blocked-process threshold were configured beforehand |
| Application timeout | A client-side timeout may not be captured by XE unless an appropriate event is configured; correlate with application logs |

## Permissions and compatibility

- Intended for SQL Server 2016+ (boxed SQL Server); validate on your exact version and edition in UAT.
- SQL Server 2016–2019: many XE DMVs and event-file reads require `VIEW SERVER STATE`.
- SQL Server 2022+: relevant XE DMVs and event-file reads generally require `VIEW SERVER PERFORMANCE STATE`.
- Metadata visibility and file access can vary by security context and platform. An XE file path must be accessible to the SQL Server service.
- XE event timestamps are UTC. Convert to local time when correlating with application logs.
- `system_health` event-file retention is limited; older deadlocks may already have rolled off.

## Production safety

All four SQL scripts are **read-only**. They do not create, start, stop, or modify XE sessions, change `sp_configure`, enable blocked-process thresholds, kill sessions, or clear diagnostics. Event-file reading can still consume CPU and I/O; use narrow time windows and avoid unnecessarily broad file patterns on busy servers.

**If an event is not already being collected:** plan a separate, reviewed change to create or modify an XE session. Do not enable high-volume events, showplan collection, or blocked-process thresholds without assessing overhead and getting approval.

## Related modules

- `03-Blocking-Deadlocks` – live blocking and `system_health` ring-buffer deadlocks
- `02-Performance-Analysis` – current requests, waits, and expensive queries
- `13-Query-Store-Analysis` – historical query and plan performance
- `05-AlwaysOn-AG` – availability and replica diagnostics

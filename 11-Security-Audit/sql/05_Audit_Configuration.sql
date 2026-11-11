SET NOCOUNT ON;
SELECT a.name,a.type_desc,a.is_state_enabled,a.queue_delay,a.on_failure_desc,f.log_file_path,f.max_file_size,f.max_rollover_files FROM sys.server_audits a LEFT JOIN sys.server_file_audits f ON f.audit_id=a.audit_id ORDER BY a.name;
SELECT s.name AS specification_name,s.is_state_enabled,d.audit_action_name,d.audited_result FROM sys.server_audit_specifications s LEFT JOIN sys.server_audit_specification_details d ON d.server_specification_id=s.server_specification_id ORDER BY s.name,d.audit_action_name;

/* 07 SQL Agent | Recent failed steps | msdb | Read-only */
SET NOCOUNT ON;
DECLARE @LookbackDays int=7;
SELECT j.name job_name,h.step_id,h.step_name,msdb.dbo.agent_datetime(h.run_date,h.run_time) failure_time,
       h.run_duration duration_hhmmss,h.sql_message_id,h.sql_severity,h.message
FROM msdb.dbo.sysjobhistory h JOIN msdb.dbo.sysjobs j ON j.job_id=h.job_id
WHERE h.run_status=0 AND h.run_date>0
  AND msdb.dbo.agent_datetime(h.run_date,h.run_time)>=DATEADD(DAY,-@LookbackDays,GETDATE())
ORDER BY h.run_date DESC,h.run_time DESC,j.name,h.step_id;

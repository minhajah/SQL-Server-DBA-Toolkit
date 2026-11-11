/* 07 SQL Agent | Job-level duration/outcome history | msdb | Read-only */
SET NOCOUNT ON;
DECLARE @LookbackDays int=30;
SELECT j.name job_name,msdb.dbo.agent_datetime(h.run_date,h.run_time) run_start_time,h.run_status,
       CASE h.run_status WHEN 0 THEN 'FAILED' WHEN 1 THEN 'SUCCEEDED' WHEN 2 THEN 'RETRY' WHEN 3 THEN 'CANCELED' WHEN 4 THEN 'IN PROGRESS' ELSE 'UNKNOWN' END run_status_desc,
       h.run_duration duration_hhmmss,
       (h.run_duration/10000)*3600+((h.run_duration%10000)/100)*60+(h.run_duration%100) duration_seconds,h.message
FROM msdb.dbo.sysjobhistory h JOIN msdb.dbo.sysjobs j ON j.job_id=h.job_id
WHERE h.step_id=0 AND h.run_date>0
  AND msdb.dbo.agent_datetime(h.run_date,h.run_time)>=DATEADD(DAY,-@LookbackDays,GETDATE())
ORDER BY run_start_time DESC,j.name;

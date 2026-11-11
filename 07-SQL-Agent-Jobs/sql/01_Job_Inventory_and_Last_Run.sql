/* 07 SQL Agent | Job inventory and last run | msdb | Read-only */
SET NOCOUNT ON;
;WITH L AS
(
 SELECT job_id,instance_id,run_status,run_date,run_time,run_duration,message,
        ROW_NUMBER() OVER(PARTITION BY job_id ORDER BY instance_id DESC) rn
 FROM msdb.dbo.sysjobhistory WHERE step_id=0
), S AS
(
 SELECT js.job_id,COUNT(*) schedule_count,SUM(CASE WHEN s.enabled=1 THEN 1 ELSE 0 END) enabled_schedule_count
 FROM msdb.dbo.sysjobschedules js JOIN msdb.dbo.sysschedules s ON s.schedule_id=js.schedule_id GROUP BY js.job_id
)
SELECT j.name job_name,j.enabled job_enabled,SUSER_SNAME(j.owner_sid) job_owner,j.date_created,j.date_modified,
       ISNULL(s.schedule_count,0) attached_schedule_count,ISNULL(s.enabled_schedule_count,0) enabled_schedule_count,
       CASE l.run_status WHEN 0 THEN 'FAILED' WHEN 1 THEN 'SUCCEEDED' WHEN 2 THEN 'RETRY' WHEN 3 THEN 'CANCELED' WHEN 4 THEN 'IN PROGRESS' ELSE 'NO HISTORY' END last_run_status,
       CASE WHEN l.run_date>0 THEN msdb.dbo.agent_datetime(l.run_date,l.run_time) END last_run_datetime,
       l.run_duration last_run_duration_hhmmss,l.message last_run_message
FROM msdb.dbo.sysjobs j LEFT JOIN L l ON l.job_id=j.job_id AND l.rn=1 LEFT JOIN S s ON s.job_id=j.job_id
ORDER BY j.enabled DESC,j.name;

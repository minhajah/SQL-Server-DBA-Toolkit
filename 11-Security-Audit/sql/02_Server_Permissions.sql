SET NOCOUNT ON;
SELECT g.name AS grantee_name,g.type_desc,pe.state_desc,pe.permission_name,pe.class_desc,pe.major_id,gr.name AS grantor_name FROM sys.server_permissions pe JOIN sys.server_principals g ON g.principal_id=pe.grantee_principal_id LEFT JOIN sys.server_principals gr ON gr.principal_id=pe.grantor_principal_id ORDER BY g.name,pe.permission_name;

SET NOCOUNT ON;
SELECT DB_NAME() AS database_name, s.name AS schema_name, o.name AS table_name, i.index_id, i.name AS index_name, i.type_desc, i.is_unique, i.is_primary_key, i.is_unique_constraint, i.is_disabled, i.has_filter, i.filter_definition, ic.key_ordinal, ic.is_included_column, ic.is_descending_key, c.name AS column_name, TYPE_NAME(c.user_type_id) AS data_type, c.max_length
FROM sys.indexes i JOIN sys.objects o ON o.object_id=i.object_id JOIN sys.schemas s ON s.schema_id=o.schema_id LEFT JOIN sys.index_columns ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id LEFT JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
WHERE o.type='U' AND i.index_id>0 ORDER BY s.name,o.name,i.index_id,ic.is_included_column,ic.key_ordinal,ic.index_column_id;

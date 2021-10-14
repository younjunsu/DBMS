SELECT
	'NON_PK' "case",
	class_name "value"
FROM
	db_class
WHERE
	class_type = 'CLASS'
	AND is_system_class = 'NO'
	AND class_name NOT IN (
		SELECT DISTINCT
			class_name
		FROM
			db_index
		WHERE
			is_primary_key = 'YES'
	)
UNION ALL
SELECT
	'SP',
	sp_name
FROM
	db_stored_procedure
UNION ALL
SELECT
	data_type,
	class_name || ' ' || attr_name AS table_column
FROM
	db_attribute
WHERE
	data_type IN (
		'CLOB',
		'BLOB'
	)
UNION ALL
SELECT
	'Serial Cache',
	name
FROM
	db_serial
WHERE
	cached_num > 0;
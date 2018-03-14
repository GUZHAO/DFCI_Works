SELECT
  OWNER,
  table_name
FROM all_tables
WHERE table_name LIKE 'MV_COBA%'
      OR table_name LIKE 'ODS_RTLS%'
      OR table_name LIKE 'ODS_EDW_ORD%'
      OR table_name LIKE 'ODS_EPSI%'
      OR table_name LIKE 'V_ODS_EPSI%'


SELECT
  OWNER,
  table_name,
  column_name
FROM all_tab_columns
WHERE column_name LIKE '%SEC%'

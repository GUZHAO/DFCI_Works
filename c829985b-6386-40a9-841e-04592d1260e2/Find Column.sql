--Find column name in all locations in EDW

USE Epic
SELECT
  SCHEMA_NAME(schema_id) AS schema_name,
  v.name                 AS view_name,
  c.name                 AS column_name
--, CASE WHEN v.name LIKE '%DRG%' THEN 1 ELSE 0 END AS BWH_DFCIViewFlag
FROM sys.views AS v
  INNER JOIN sys.columns c ON v.OBJECT_ID = c.OBJECT_ID
WHERE c.name LIKE '%LINENBR%'
ORDER BY schema_name, view_name, column_name


--WHERE c.name = 'PatientID'
--ORDER BY schema_name, table_name;

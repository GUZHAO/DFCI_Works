----------
SELECT
  PatientEncounterID,
  ProviderID,
  AttendingStartDTS,
  ROW_NUMBER()
  OVER ( PARTITION BY PatientEncounterID
    ORDER BY AttendingStartDTS,
      ProviderID
    ) AS rn
FROM [Epic].[Encounter].[HospitalAttendingProvider_DFCI]
WHERE ProviderID NOT LIKE 'E%'
GROUP BY PatientEncounterID,
  ProviderID,
  AttendingStartDTS
ORDER BY PatientEncounterID;

----------
DROP TABLE DFCICOBA.MyTable;
CREATE TABLE DFCICOBA.MyTable (
  Site VARCHAR(10),
  Date DATE
);

INSERT INTO DFCICOBA.MyTable (Site, Date)
VALUES ('LW', '2018-01-11')
INSERT INTO DFCICOBA.MyTable (Site, Date)
VALUES ('LW', '2018-01-05')
INSERT INTO DFCICOBA.MyTable (Site, Date)
VALUES ('SS', '2018-01-14')
INSERT INTO DFCICOBA.MyTable (Site, Date)
VALUES ('LW', '2018-01-24')
INSERT INTO DFCICOBA.MyTable (Site, Date)
VALUES ('LW', '2018-02-01')
INSERT INTO DFCICOBA.MyTable (Site, Date)
VALUES ('SS', '2018-02-14')
INSERT INTO DFCICOBA.MyTable (Site, Date)
VALUES ('SS', '2018-03-01')
INSERT INTO DFCICOBA.MyTable (Site, Date)
VALUES ('SS', '2018-04-02')

--Test One -not working - can not retain CNT value
DECLARE @CNT INT = 1, @loopstoper INT = 1
WHILE @loopstoper < 8
  BEGIN
    SELECT
      t2.Site,
      t2.Date,
      t2.Site_Lag,
      CASE
      WHEN t2.Site = t2.Site_lag
        THEN @CNT
      WHEN t2.Site_lag IS NULL
        THEN @CNT
      ELSE @CNT + 1 END AS Seq
    FROM (SELECT
            t1.Site,
            t1.Date,
            LAG(t1.Site)
            OVER (
              ORDER BY t1.Date ) AS Site_Lag
          FROM DFCICOBA.MyTable t1) t2;

    SET @loopstoper = @loopstoper + 1
  END;

-----------
DECLARE @temp TABLE([row] INT IDENTITY, [Site] VARCHAR(20), [Date] DATE)
INSERT INTO @temp([Site], [Date]) VALUES ('LW', '2018-01-11')
INSERT INTO @temp([Site], [Date]) VALUES ('LW', '2018-01-05')
INSERT INTO @temp([Site], [Date]) VALUES ('SS', '2018-01-14')
INSERT INTO @temp([Site], [Date]) VALUES ('LW', '2018-01-24')
INSERT INTO @temp([Site], [Date]) VALUES ('LW', '2018-02-01')
INSERT INTO @temp([Site], [Date]) VALUES ('SS', '2018-02-14')
INSERT INTO @temp([Site], [Date]) VALUES ('SS', '2018-03-01')
INSERT INTO @temp([Site], [Date]) VALUES ('SS', '2018-04-02')

SELECT *
FROM @temp;

--DECLARE @int INT = 0;
--Test Two - worked - will have performance issue as it's processed row by row
WITH CTE AS (
  SELECT
    *,
    1 AS incr
  FROM @temp
  WHERE row = 1
  UNION ALL
  SELECT
    t.*,
    CASE WHEN t.Site = c.Site
      THEN incr
    ELSE incr + 1 END
  FROM @temp t INNER JOIN CTE c
      ON t.row = c.row + 1
)

SELECT *
FROM CTE
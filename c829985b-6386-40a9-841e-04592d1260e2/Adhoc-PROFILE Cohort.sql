SELECT COUNT(DISTINCT t1.PatientID) AS CNT
FROM (
  SELECT DISTINCT
    t1.PatientID,
    t1.AppointmentDTS,
    t1.ContactDTS,
    t1.EpicLocationID,
    t2.RevenueLocationNM
  FROM EPIC.Encounter.PatientEncounter_DFCI t1
    LEFT JOIN EPIC.Reference.Location t2 ON t1.EpicLocationID = t2.LocationID
  WHERE
    t2.RevenueLocationNM LIKE 'DANA%' AND
    --         'DANA-FARBER CANCER INSTITUTE LONGWOOD',
    --         'DANA-FARBER AT ST. ELIZABETH MEDICAL CENTER',
    --         'DANA-FARBER BWCC AT MILFORD REGIONAL MEDICAL CENTER',
    --         'DANA-FARBER BWCC SOUTH SHORE CANCER CENTER',
    --         'DANA-FARBER LONDONDERRY')
    YEAR(t1.ContactDTS) >= 2017
) t1
;

SELECT DISTINCT
  t1.RevenueLocationNM
FROM EPIC.Reference.Location t1
WHERE t1.RevenueLocationNM LIKE 'DANA%'
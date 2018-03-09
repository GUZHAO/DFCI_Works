SELECT
  t1.Department_Name,
  COUNT(DISTINCT t1.DFCI_MRN) AS CNT
FROM UserWork.DFCICOBA.INPCMS_Test t1
WHERE t1.Department_Name LIKE '%BWH DF%'
GROUP BY t1.Department_Name

SELECT
  t1.Department_Name,
  AVG(t1.CNT)
FROM
  (SELECT DISTINCT
     t1.DFCI_MRN,
     t1.Department_Name,
     t1.Admission_DTS,
     t1.Discharge_DTS,
     DATEDIFF(DAY, t1.Admission_DTS, t1.Discharge_DTS) AS CNT
   FROM UserWork.DFCICOBA.INPCMS_Test t1
   WHERE t1.Department_Name LIKE '%BWH DF%') t1
GROUP BY t1.Department_Name


SELECT
  t1.*,
  DATEDIFF(DAY, t1.Admission_DTS, t1.Discharge_DTS) AS CNT,
  t2.ADTEventTypeDSC,
  t3.DRGRecordID,
  t4.DRG
FROM UserWork.DFCICOBA.INPCMS_Test t1
  LEFT JOIN EPIC.Encounter.ADT_DFCI t2 ON t1.Encounter_ID = t2.PatientEncounterID
  LEFT JOIN Finance.HospitalAccountDRG_DFCI t3 ON t1.HospitalAccountID = t3.HospitalAccountID
  LEFT JOIN Reference.DRG t4 ON t3.DRGRecordID = t4.DRGRecordID
WHERE t1.Department_Name LIKE '%BWH DF%'

SELECT
  t1.PatientEncounterID, t1.ProcedureDSC,
  CASE WHEN t1.ProcedureDSC LIKE '%EKG%' OR
            t1.ProcedureDSC LIKE '%TTE%' OR
            t1.ProcedureDSC LIKE '%CATHETERIZATION%' OR
            t1.ProcedureDSC LIKE '%PULMONARY%FUNCTION%TEST%' OR
            t1.ProcedureDSC LIKE '%XR%CHEST%'
    THEN 'Y'
  ELSE 'N' END AS DiagnosisTest
FROM Epic.Orders.Procedure_DFCI t1
WHERE t1.PatientEncounterID = 3071760389

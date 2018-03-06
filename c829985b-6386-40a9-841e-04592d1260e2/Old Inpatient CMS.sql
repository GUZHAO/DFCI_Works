-- tableau       AS Inpatient Location,
SELECT
  t6.MRN                  AS DFCI_MRN,
  t2.PatientID            AS Patient_ID,
  t2.PatientEncounterID   AS Encounter_ID,
  t5.PatientNM            AS PatientName,
  t1.DepartmentDSC        AS Department_Name,
  t2.OrderingDTS          AS Procedure_Order_DTS,
  t1.HospitalAdmitDTS     AS Admission_DTS,
  t1.HospitalDischargeDTS AS Discharge_DTS,
  t2.StartDTS             AS Procedure_Start_DTS,
  t2.EndDTS               AS Procedure_End_DTS,
  t2.ProcedureCD          AS Procedure_CD,
  t2.ProcedureDSC         AS Procedure_Name,
  t2.CPT                  AS CPT_Name,
  t3.DiagnosisFlag,
  NULL                    AS Consent_Type,
  NULL                    AS Consent_Date,
  NULL                    AS Consent_Department_Name,
  NULL                    AS Medication_Name,
  NULL                    AS Medication_Order_DTS,
  NULL                    AS EntryTimeDTS,
  NULL                    AS BaselineVitalFlag,
  NULL                    AS AirwayFlag,
  NULL                    AS ComplicationAdverseFlag,
  NULL                    AS NOTE_DTS,
  NULL                    AS HPFlag,
  NULL                    AS OPNoteFlag
FROM Epic.Orders.Procedure_DFCI t2
  LEFT JOIN (
              SELECT DISTINCT
                t1.PatientEncounterID,
                CASE WHEN t1.DiagnosisID IS NOT NULL
                  THEN 'Y'
                ELSE 'N' END AS DiagnosisFlag
              FROM Epic.Orders.DiagnosisProcedure_DFCI t1
              WHERE t1.DiagnosisID IS NOT NULL
            ) t3
    ON t2.PatientEncounterID = t3.PatientEncounterID
  LEFT JOIN Epic.Encounter.PatientEncounterHospital_DFCI t1
    ON t2.PatientEncounterID = t1.PatientEncounterID
  LEFT JOIN Epic.Patient.Patient_DFCI t5
    ON t2.PatientID = t5.PatientID
  LEFT JOIN (
              SELECT
                t1.EDWPatientID,
                t1.MRN
              FROM Integration.EMPI.MRN_DFCI t1
              WHERE t1.StatusCD = 'A'
            ) t6
    ON t5.EDWPatientID = t6.EDWPatientID
WHERE
  t2.PatientID IN (
    SELECT t1.PatientID
    FROM Epic.Encounter.PatientEncounterHospital_DFCI t1
    WHERE t1.DepartmentID IN (10030010022, 10030010024, 10030010026)
  )
  AND YEAR(t2.OrderingDTS) >= 2017

UNION


SELECT
  t3.MRN                          AS DFCI_MRN,
  t1.PatientID,
  NULL                            AS Encounter_ID,
  NULL                            AS PatientName,
  NULL                            AS Department_Name,
  NULL                            AS Procedure_Order_DTS,
  NULL                            AS Admission_DTS,
  NULL                            AS Discharge_DTS,
  NULL                            AS Procedure_Start_DTS,
  NULL                            AS Procedure_End_DTS,
  NULL                            AS Procedure_CD,
  NULL                            AS Procedure_Name,
  NULL                            AS CPT_Name,
  NULL                            AS DiagnosisFlag,
  t1.DocumentTypeDSC              AS Consent_Type,
  t1.DocumentDTS                  AS Consent_Date,
  t1.DocumentCreatedDepartmentDSC AS Consent_Department_Name,
  NULL                            AS Medication_Name,
  NULL                            AS Medication_Order_DTS,
  NULL                            AS EntryTimeDTS,
  NULL                            AS BaselineVitalFlag,
  NULL                            AS AirwayFlag,
  NULL                            AS ComplicationAdverseFlag,
  NULL                            AS Note_DTS,
  NULL                            AS HPFlag,
  NULL                            AS OPNoteFlag
FROM Epic.Encounter.DocumentInformation_DFCI t1
  LEFT JOIN Epic.Patient.Patient_DFCI t2
    ON t1.PatientID = t2.PatientID
  LEFT JOIN (
              SELECT
                t1.EDWPatientID,
                t1.MRN
              FROM Integration.EMPI.MRN_DFCI t1
              WHERE t1.StatusCD = 'A'
            ) t3
    ON t2.EDWPatientID = t3.EDWPatientID
WHERE
  t1.PatientID IN (
    SELECT t1.PatientID
    FROM Epic.Encounter.PatientEncounterHospital_DFCI t1
    WHERE t1.DepartmentID IN (10030010022, 10030010024, 10030010026)
  ) AND t1.DocumentTypeDSC LIKE '%CONSENT%'
  AND (
    t1.DocumentCreatedDepartmentDSC LIKE '%DF%'
    OR t1.DocumentCreatedDepartmentDSC LIKE '%BW%'
  )
  AND t1.DocumentDTS IS NOT NULL
  AND YEAR(t1.DocumentDTS) >= 2017

UNION

SELECT
  t3.MRN                AS DFCI_MRN,
  t1.PatientID,
  t1.PatientEncounterID AS Encounter_ID,
  NULL                  AS PatientName,
  NULL                  AS Department_Name,
  NULL                  AS Procedure_Order_DTS,
  NULL                  AS Admission_DTS,
  NULL                  AS Discharge_DTS,
  NULL                  AS Procedure_Start_DTS,
  NULL                  AS Procedure_End_DTS,
  NULL                  AS Procedure_CD,
  NULL                  AS Procedure_Name,
  NULL                  AS CPT_Name,
  NULL                  AS DiagnosisFlag,
  NULL                  AS Consent_Type,
  NULL                  AS Consent_Date,
  NULL                  AS Consent_Department_Name,
  t1.MedicationDSC      AS Medication_Name,
  t1.OrderDTS           AS Medication_Order_DTS,
  NULL                  AS EntryTimeDTS,
  NULL                  AS BaselineVitalFlag,
  NULL                  AS AirwayFlag,
  NULL                  AS ComplicationAdverseFlag,
  NULL                  AS Note_DTS,
  NULL                  AS HPFlag,
  NULL                  AS OPNoteFlag
FROM Epic.Orders.Medication_DFCI t1
  LEFT JOIN Epic.Patient.Patient_DFCI t2
    ON t1.PatientID = t2.PatientID
  LEFT JOIN (
              SELECT
                t1.EDWPatientID,
                t1.MRN
              FROM Integration.EMPI.MRN_DFCI t1
              WHERE t1.StatusCD = 'A'
            ) t3
    ON t2.EDWPatientID = t3.EDWPatientID
WHERE
  t1.PatientID IN (
    SELECT t1.PatientID
    FROM Epic.Encounter.PatientEncounterHospital_DFCI t1
    WHERE t1.DepartmentID IN (10030010022, 10030010024, 10030010026)
  ) AND YEAR(t1.OrderDTS) >= 2017
  AND (t1.PatientLocationDSC LIKE '%BW%'
       OR t1.PatientLocationDSC LIKE '%DF%')

UNION

SELECT DISTINCT
  t5.MRN       AS DFCI_MRN,
  t2.PatientID,
  NULL         AS Encounter_ID,
  NULL         AS PatientName,
  NULL         AS Department_Name,
  NULL         AS Procedure_Order_DTS,
  NULL         AS Admission_DTS,
  NULL         AS Discharge_DTS,
  NULL         AS Procedure_Start_DTS,
  NULL         AS Procedure_End_DTS,
  NULL         AS Procedure_CD,
  NULL         AS Procedure_Name,
  NULL         AS CPT_Name,
  NULL         AS DiagnosisFlag,
  NULL         AS Consent_Type,
  NULL         AS Consent_Date,
  NULL         AS Consent_Department_Name,
  NULL         AS Medication_Name,
  NULL         AS Medication_Order_DTS,
  t1.EntryTimeDTS,
  CASE WHEN t3.FlowsheetMeasureNM LIKE '%VITAL%'
    THEN 'Y'
  ELSE 'N' END AS BaselineVitalFlag,
  CASE WHEN t3.FlowsheetMeasureNM LIKE '%AIRWAY%'
    THEN 'Y'
  ELSE 'N' END AS AirwayFlag,
  CASE WHEN (t3.FlowsheetMeasureNM LIKE '%COMPLICATIONS%' OR t3.FlowsheetMeasureNM LIKE '%ADVERSE%')
    THEN 'Y'
  ELSE 'N' END AS ComplicationAdverseFlag,
  NULL         AS Note_DTS,
  NULL         AS HPFlag,
  NULL         AS OPNoteFlag
FROM Epic.Clinical.FlowsheetMeasure_DFCI t1
  LEFT JOIN Epic.Clinical.FlowsheetRecordLink_DFCI t2 ON t1.FlowsheetDataID = t2.FlowsheetDataID
  LEFT JOIN Epic.Clinical.FlowsheetGroup_DFCI t3 ON t1.FlowsheetMeasureID = t3.FlowsheetMeasureID
  LEFT JOIN Epic.Patient.Patient_DFCI t4
    ON t2.PatientID = t4.PatientID
  LEFT JOIN (
              SELECT
                t1.EDWPatientID,
                t1.MRN
              FROM Integration.EMPI.MRN_DFCI t1
              WHERE t1.StatusCD = 'A'
            ) t5
    ON t4.EDWPatientID = t5.EDWPatientID
WHERE
  t2.PatientID IN (
    SELECT t1.PatientID
    FROM Epic.Encounter.PatientEncounterHospital_DFCI t1
    WHERE t1.DepartmentID IN (10030010022, 10030010024, 10030010026)
  )
  AND YEAR(t2.RecordDTS) >= 2017
  AND t1.IsAcceptedFLG = 'Y'
  AND (t3.FlowsheetMeasureNM LIKE '%VITAL%'
       OR t3.FlowsheetMeasureNM LIKE '%AIRWAY%'
       OR t3.FlowsheetMeasureNM LIKE '%COMPLICATION%'
       OR t3.FlowsheetMeasureNM LIKE '%ADVERSE%')

UNION

SELECT DISTINCT
  t3.MRN                AS DFCI_MRN,
  t1.PatientID,
  t1.PatientEncounterID AS Encounter_ID,
  NULL                  AS PatientName,
  NULL                  AS Department_Name,
  NULL                  AS Procedure_Order_DTS,
  NULL                  AS Admission_DTS,
  NULL                  AS Discharge_DTS,
  NULL                  AS Procedure_Start_DTS,
  NULL                  AS Procedure_End_DTS,
  NULL                  AS Procedure_CD,
  NULL                  AS Procedure_Name,
  NULL                  AS CPT_Name,
  NULL                  AS DiagnosisFlag,
  NULL                  AS Consent_Type,
  NULL                  AS Consent_Date,
  NULL                  AS Consent_Department_Name,
  NULL                  AS Medication_Name,
  NULL                  AS Medication_Order_DTS,
  NULL                  AS EntryTimeDTS,
  NULL                  AS BaselineVitalFlag,
  NULL                  AS AirwayFlag,
  NULL                  AS ComplicationAdverseFlag,
  t1.DateOfServiceDTS   AS Note_DTS,
  CASE WHEN t1.NoteTypeNoAddDSC LIKE '%H&P Note%'
    THEN 'Y'
  ELSE 'N' END          AS HPFlag,
  CASE WHEN t1.NoteTypeNoAddDSC LIKE '%Procedure Note%'
    THEN 'Y'
  ELSE 'N' END          AS OPNoteFlag
FROM Epic.Clinical.Note_DFCI t1
  LEFT JOIN Epic.Patient.Patient_DFCI t2
    ON t1.PatientID = t2.PatientID
  LEFT JOIN (
              SELECT
                t1.EDWPatientID,
                t1.MRN
              FROM Integration.EMPI.MRN_DFCI t1
              WHERE t1.StatusCD = 'A'
            ) t3
    ON t2.EDWPatientID = t3.EDWPatientID
WHERE
  t1.PatientID IN (
  SELECT t1.PatientID
  FROM Epic.Encounter.PatientEncounterHospital_DFCI t1
  WHERE t1.DepartmentID IN (10030010022, 10030010024, 10030010026)
) AND
      (t1.NoteTypeNoAddDSC LIKE '%H&P Note%'
       OR t1.NoteTypeNoAddDSC LIKE '%Procedure Note%')
      AND YEAR(t1.DateOfServiceDTS) >= 2017;





--Check if the primary key is unique
SELECT
  t1.PatientID,
  COUNT(t1.PatientID) AS CNT
FROM Epic.Patient.Patient_DFCI t1
GROUP BY t1.PatientID
ORDER BY CNT DESC

--Check if the primary key is unique
SELECT
  t1.EDWPatientID,
  --  t1.MRN,
  COUNT(t1.EDWPatientID) AS CNT
FROM Integration.EMPI.MRN_DFCI t1
WHERE t1.StatusCD = 'A'
GROUP BY
  t1.EDWPatientID
--  t1.MRN
ORDER BY CNT DESC

SELECT t1.*
FROM Integration.EMPI.MRN_DFCI t1
WHERE t1.EDWPatientID = 1095225

--Check if the primary key is unique
SELECT
  t1.PatientEncounterID,
  COUNT(t1.PatientEncounterID) AS CNT
FROM Epic.Encounter.PatientEncounterHospital_DFCI t1
GROUP BY t1.PatientEncounterID
ORDER BY CNT DESC

--Check if the primary key is unique
SELECT
  t1.PatientID,
  COUNT(t1.PatientID) AS CNT
FROM Epic.Encounter.DocumentInformation_DFCI t1
WHERE t1.DocumentTypeDSC LIKE '%CONSENT%'
      AND (
        t1.DocumentCreatedDepartmentDSC LIKE '%DF%'
        OR t1.DocumentCreatedDepartmentDSC LIKE '%BW%'
      )
      AND t1.DocumentDTS IS NOT NULL
      AND YEAR(t1.DocumentDTS) >= 2017
GROUP BY t1.PatientID
ORDER BY CNT DESC

SELECT
  t1.PatientID,
  t1.DocumentTypeDSC,
  t1.DocumentDTS,
  t1.DocumentCreatedDepartmentDSC
FROM Epic.Encounter.DocumentInformation_DFCI t1
WHERE t1.DocumentTypeDSC LIKE '%CONSENT%'
      AND (
        t1.DocumentCreatedDepartmentDSC LIKE '%DF%'
        OR t1.DocumentCreatedDepartmentDSC LIKE '%BW%'
      )
      AND t1.DocumentDTS IS NOT NULL
      AND YEAR(t1.DocumentDTS) >= 2017
      AND t1.PatientID = 'Z7412639';

--Check if the primary key is unique
SELECT
  t1.PatientEncounterID,
  t1.DiagnosisFlag,
  COUNT(t1.PatientEncounterID) AS CNT
FROM (
       SELECT DISTINCT
         --  t1.PatientID,
         t1.PatientEncounterID,
         CASE WHEN t1.DiagnosisID IS NOT NULL
           THEN 'Y'
         ELSE 'N' END AS DiagnosisFlag

       FROM Epic.Orders.DiagnosisProcedure_DFCI t1
       WHERE t1.DiagnosisID IS NOT NULL
     ) t1
GROUP BY
  --  t1.PatientID,
  t1.PatientEncounterID,
  t1.DiagnosisFlag
ORDER BY
  CNT DESC

--Check if the primary key is unique
SELECT
  t1.PatientID,
  t1.PatientEncounterID,
  t1.MedicationDSC,
  t1.OrderDTS,
  t1.PatientLocationDSC
FROM Epic.Orders.Medication_DFCI t1
WHERE YEAR(t1.OrderDTS) >= 2017
      AND (t1.PatientLocationDSC LIKE '%BW%'
           OR t1.PatientLocationDSC LIKE '%DF%')

--Check if the primary key is unique
SELECT DISTINCT
  t2.PatientID,
  t1.IsAcceptedFLG,
  t2.RecordDTS,
  t1.UpdateDTS,
  t1.EntryTimeDTS,
  t3.FlowsheetMeasureNM
--  COUNT(t2.PatientID) AS CNT
FROM Epic.Clinical.FlowsheetMeasure_DFCI t1
  LEFT JOIN Epic.Clinical.FlowsheetRecordLink_DFCI t2 ON t1.FlowsheetDataID = t2.FlowsheetDataID
  LEFT JOIN Epic.Clinical.FlowsheetGroup_DFCI t3 ON t1.FlowsheetMeasureID = t3.FlowsheetMeasureID
WHERE t2.PatientID IS NOT NULL
      AND YEAR(t2.RecordDTS) >= 2017
      AND t1.IsAcceptedFLG = 'Y'
      AND t3.FlowsheetMeasureNM LIKE '%ADVERSE%'

SELECT DISTINCT
  t2.PatientID,
  t1.IsAcceptedFLG,
  t2.RecordDTS,
  t3.FlowsheetMeasureNM
--  COUNT(t2.PatientID) AS CNT
FROM Epic.Clinical.FlowsheetMeasure_DFCI t1
  LEFT JOIN Epic.Clinical.FlowsheetRecordLink_DFCI t2 ON t1.FlowsheetDataID = t2.FlowsheetDataID
  LEFT JOIN Epic.Clinical.FlowsheetGroup_DFCI t3 ON t1.FlowsheetMeasureID = t3.FlowsheetMeasureID
WHERE t2.PatientID IS NOT NULL
      AND YEAR(t2.RecordDTS) >= 2017
      AND t1.IsAcceptedFLG = 'Y'
      AND t3.FlowsheetMeasureNM LIKE '%COMPLICATION%'

-- GROUP BY
--   t2.PatientID,
--   t1.IsAcceptedFLG,
--   t2.RecordDTS
-- ORDER BY
--   CNT DESC

SELECT
  t1.FlowsheetDataID,
  t1.PatientID,
  COUNT(t1.FlowsheetDataID) AS CNT
FROM Epic.Clinical.FlowsheetRecordLink_DFCI t1
GROUP BY
  t1.FlowsheetDataID,
  t1.PatientID
ORDER BY CNT DESC

--Check if the primary key is unique
SELECT TOP 400
  t1.FlowsheetMeasureID,
  t1.FlowsheetMeasureNM,
  t1.FlowsheetDSC,
  t1.FlowsheetDisplayNM
FROM Epic.Clinical.FlowsheetGroup_DFCI t1
WHERE t1.FlowsheetMeasureNM LIKE '%ORAL%'

--Check if the primary key is unique
SELECT TOP 400
  t1.PatientEncounterID,
  t1.NoteCreateSourceDSC,
  t1.NoteStatusDSC,
  t1.ContactDTS,
  t1.NoteFiledDTS
FROM Epic.Clinical.NoteEncounterInformation_DFCI t1
WHERE t1.PatientEncounterID IS NOT NULL

SELECT DISTINCT
  t1.NoteTypeNoAddDSC,
  t1.PatientEncounterID,
  t1.PatientID,
  t1.DateOfServiceDTS
FROM Epic.Clinical.Note_DFCI t1
WHERE (t1.NoteTypeNoAddDSC LIKE '%H&P Note%'
       OR t1.NoteTypeNoAddDSC LIKE '%Procedure Note%')
      AND t1.DateOfServiceDTS >= 2017
ORDER BY t1.PatientID
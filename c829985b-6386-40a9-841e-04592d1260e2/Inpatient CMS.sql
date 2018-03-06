--Inpatient CMS Project
--Add inpatient outpatient indicator
SELECT
  t4.MRN                  AS DFCI_MRN,
  t1.PatientID            AS Patient_ID,
  t1.PatientEncounterID   AS Encounter_ID,
  t3.PatientNM            AS PatientName,
  t1.OrderingModeDSC      AS PatientType,
  t2.DepartmentDSC        AS Department_Name,
  t2.HospitalAdmitDTS     AS Admission_DTS,
  t2.HospitalDischargeDTS AS Discharge_DTS,
  t1.StartDTS             AS Procedure_Start_DTS,
  t1.EndDTS               AS Procedure_End_DTS,
  t1.ProcedureDSC         AS Procedure_Name,
  t1.CPT                  AS CPT_Name,
  t5.DiagnosisEntryDTS,
  t6.ScannedDTS,
  t6.ConsentFormUsed,
  t6.ConsentFlag,
  --   t7.CurrentMedication,
  t8.HPFlag,
  t8.ServiceDTS           AS HP_ServiceDTS,
  t9.OPNoteFlag,
  t9.ServiceDTS           AS OPNote_ServiceDTS,
  t10.BaselineVitalFlag,
  t11.AirwayFlag,
  t12.ComplicationAdverseFlag,
  t10.EntryTimeDTS AS Vital_EntryDTS,
  t11.EntryTimeDTS AS Airway_EntryDTS,
  t12.EntryTimeDTS AS Complication_EntryDTS
FROM (
       SELECT DISTINCT
         tt1.PatientID,
         tt1.PatientEncounterID,
         tt1.OrderDTS,
         tt1.StartDTS,
         tt1.EndDTS,
         tt1.ProcedureDSC,
         tt1.CPT,
         tt2.OrderingModeDSC
       FROM Epic.Orders.Procedure_DFCI tt1
         LEFT JOIN Epic.Orders.Procedure3_DFCI tt2 ON tt1.OrderProcedureID = tt2.OrderID
       WHERE tt1.PatientEncounterID IS NOT NULL
     ) t1
  LEFT JOIN (
              SELECT DISTINCT
                tt1.PatientEncounterID,
                tt1.DepartmentDSC,
                tt1.HospitalAdmitDTS,
                tt1.HospitalDischargeDTS
              FROM Epic.Encounter.PatientEncounterHospital_DFCI tt1
            ) t2
    ON t1.PatientEncounterID = t2.PatientEncounterID
  LEFT JOIN Epic.Patient.Patient_DFCI t3
    ON t1.PatientID = t3.PatientID
  LEFT JOIN (
              SELECT
                tt2.EDWPatientID,
                tt2.MRN
              FROM Integration.EMPI.MRN_DFCI tt2
              WHERE tt2.StatusCD = 'A'
            ) t4
    ON t3.EDWPatientID = t4.EDWPatientID
  LEFT JOIN (
              SELECT DISTINCT
                t1.PatientID,
                t1.DiagnosisEntryDTS
              FROM Epic.Patient.ProblemList_DFCI t1
            ) t5
    ON t1.PatientID = t5.PatientID AND CAST(t1.StartDTS AS DATE) = t5.DiagnosisEntryDTS
  LEFT JOIN (
              SELECT DISTINCT
                t1.ScannedDTS,
                t1.PatientEncounterID,
                CASE WHEN t1.DocumentCreatedDepartmentDSC LIKE '%DF%'
                  THEN 'DFCI'
                WHEN t1.DocumentCreatedDepartmentDSC LIKE '%BWP%'
                  THEN 'BWP'
                WHEN t1.DocumentCreatedDepartmentDSC LIKE '%BWH%'
                  THEN 'BWH'
                WHEN t1.DocumentCreatedDepartmentDSC LIKE '%BWF%'
                  THEN 'BWF'
                ELSE 'OTHER'
                END AS ConsentFormUsed,
                'Y' AS ConsentFlag
              FROM Epic.Encounter.DocumentInformation_DFCI t1
              WHERE
                t1.DocumentTypeCD = '110017'
            ) t6
    ON t1.PatientEncounterID = t6.PatientEncounterID AND CAST(t1.StartDTS AS DATE) = CAST(t6.ScannedDTS AS DATE)
  LEFT JOIN (
              SELECT
                t1.PatientEncounterID,
                t1.DateOfServiceDTS AS ServiceDTS,
                t1.InpatientNoteTypeDSC,
                'Y'                 AS HPFlag
              FROM Epic.Clinical.Note_DFCI t1
              WHERE t1.NoteTypeNoAddDSC LIKE '%H&P Note%'
                    AND YEAR(t1.DateOfServiceDTS) > 2016
            ) t8
    ON t1.PatientEncounterID = t8.PatientEncounterID AND CAST(t1.StartDTS AS DATE) = CAST(t8.ServiceDTS AS DATE)
  LEFT JOIN (
              SELECT DISTINCT
                t1.PatientEncounterID,
                t1.DateOfServiceDTS AS ServiceDTS,
                'Y'                 AS OPNoteFlag
              FROM Epic.Clinical.Note_DFCI t1
              WHERE t1.NoteTypeNoAddDSC LIKE '%Procedure Note%'
            ) t9
    ON t1.PatientEncounterID = t9.PatientEncounterID AND CAST(t1.StartDTS AS DATE) = CAST(t9.ServiceDTS AS DATE)
  LEFT JOIN (
              SELECT DISTINCT
                t2.PatientID,
                t1.EntryTimeDTS,
                'Y'                                             AS BaselineVitalFlag
              FROM Epic.Clinical.FlowsheetMeasure_DFCI t1
                LEFT JOIN Epic.Clinical.FlowsheetRecordLink_DFCI t2 ON t1.FlowsheetDataID = t2.FlowsheetDataID
                LEFT JOIN Epic.Clinical.FlowsheetGroup_DFCI t3 ON t1.FlowsheetMeasureID = t3.FlowsheetMeasureID
              WHERE t1.IsAcceptedFLG = 'Y' AND t3.FlowsheetMeasureNM LIKE '%VITAL%'
            ) t10 ON t1.PatientID = t10.PatientID AND CAST(t1.StartDTS AS DATE) = CAST(t10.EntryTimeDTS AS DATE)
  LEFT JOIN (
              SELECT DISTINCT
                t2.PatientID,
                t1.EntryTimeDTS,
                'Y'                                             AS AirwayFlag
              FROM Epic.Clinical.FlowsheetMeasure_DFCI t1
                LEFT JOIN Epic.Clinical.FlowsheetRecordLink_DFCI t2 ON t1.FlowsheetDataID = t2.FlowsheetDataID
                LEFT JOIN Epic.Clinical.FlowsheetGroup_DFCI t3 ON t1.FlowsheetMeasureID = t3.FlowsheetMeasureID
              WHERE t1.IsAcceptedFLG = 'Y' AND t3.FlowsheetMeasureNM LIKE '%AIRWAY%'
            ) t11 ON t1.PatientID = t11.PatientID AND CAST(t1.StartDTS AS DATE) = CAST(t11.EntryTimeDTS AS DATE)
  LEFT JOIN (
              SELECT DISTINCT
                t2.PatientID,
                t1.EntryTimeDTS,
                'Y'                                             AS ComplicationAdverseFlag
              FROM Epic.Clinical.FlowsheetMeasure_DFCI t1
                LEFT JOIN Epic.Clinical.FlowsheetRecordLink_DFCI t2 ON t1.FlowsheetDataID = t2.FlowsheetDataID
                LEFT JOIN Epic.Clinical.FlowsheetGroup_DFCI t3 ON t1.FlowsheetMeasureID = t3.FlowsheetMeasureID
              WHERE t1.IsAcceptedFLG = 'Y' AND
                    (t3.FlowsheetMeasureNM LIKE '%COMPLICATIONS%' OR t3.FlowsheetMeasureNM LIKE '%ADVERSE%')
            ) t12 ON t1.PatientID = t12.PatientID AND CAST(t1.StartDTS AS DATE) = CAST(t12.EntryTimeDTS AS DATE)
WHERE
  t1.PatientID IN (
    SELECT a1.PatientID
    FROM Epic.Encounter.PatientEncounterHospital_DFCI a1
    WHERE a1.DepartmentID IN (10030010022, 10030010024, 10030010026)
  ) AND YEAR(t2.HospitalAdmitDTS) >= 2017;

--Medication Wrong Version
--   LEFT JOIN (
--               SELECT DISTINCT
--                 t1.PatientEncounterID,
--                 CASE WHEN t1.MedicationDSC IS NOT NULL
--                   THEN 'Y'
--                 ELSE 'N'
--                 END AS CurrentMedication,
--                 t1.OrderDTS
--               FROM Epic.Orders.Medication_DFCI t1
--                 LEFT JOIN Epic.Reference.Department t2 ON t1.PatientLocationID = t2.DepartmentID
--               WHERE
--                 (t2.DepartmentNM LIKE '%BW%'
--                  OR t2.DepartmentNM LIKE '%DF%')
--             ) t7 ON t1.PatientEncounterID = t7.PatientEncounterID AND
--                     (CASE WHEN t2.HospitalDischargeDTS IS NOT NULL AND t2.HospitalAdmitDTS <= t7.OrderDTS AND
--                                t7.OrderDTS <= t2.HospitalDischargeDTS
--                       THEN 1
--                      WHEN t2.HospitalDischargeDTS IS NULL AND t2.HospitalAdmitDTS <= t7.OrderDTS
--                        THEN 1
--                      ELSE 0
--                      END) = 1
-- ;


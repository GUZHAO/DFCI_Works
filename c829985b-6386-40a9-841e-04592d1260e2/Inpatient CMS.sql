--Inpatient CMS Project
--Add inpatient outpatient indicator
SELECT
  t4.MRN                  AS DFCI_MRN,
  t1.PatientID            AS Patient_ID,
  t1.PatientEncounterID   AS Encounter_ID,
  t3.PatientNM            AS PatientName,
  t2.DepartmentDSC        AS Department_Name,
  t2.HospitalAdmitDTS     AS Admission_DTS,
  t2.HospitalDischargeDTS AS Discharge_DTS,
  t1.StartDTS             AS Procedure_Start_DTS,
  CASE WHEN t1.EndDTS IS NOT NULL
    THEN 'Y'
  ELSE 'N' END            AS TimeOut,
  t1.ProcedureDSC         AS Procedure_Name,
  t1.CPT                  AS CPT_Name
--   t5.DiagnosisFlag,
--   t6.ConsentFormUsed,
--   t7.CurrentMedication,
--   t8.HPFlag,
--   t9.OPNoteFlag,
--   t10.BaselineVitalFlag,
--   t10.AirwayFlag,
--   t10.ComplicationAdverseFlag
FROM Epic.Orders.Procedure_DFCI t1
  LEFT JOIN (SELECT DISTINCT
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
                t1.DiagnosisEntryDTS,
                'Y' AS DiagnosisFlag
              FROM Epic.Patient.ProblemList_DFCI t1
            ) t5
    ON t1.PatientID = t5.PatientID AND
       (CASE WHEN t2.HospitalDischargeDTS IS NOT NULL AND t2.HospitalAdmitDTS <= t5.DiagnosisEntryDTS AND
                  t5.DiagnosisEntryDTS <= t2.HospitalDischargeDTS
         THEN 1
        WHEN t2.HospitalDischargeDTS IS NULL AND t2.HospitalAdmitDTS <= t5.DiagnosisEntryDTS
          THEN 1
        ELSE 0
        END) = 1
  LEFT JOIN (
              SELECT DISTINCT
                t1.PatientID,
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
                END AS ConsentFormUsed
              FROM Epic.Encounter.DocumentInformation_DFCI t1
              WHERE
                t1.DocumentTypeCD = '110017'
                AND (t1.DocumentCreatedDepartmentDSC LIKE '%DF%'
                     OR t1.DocumentCreatedDepartmentDSC LIKE '%BWH%'
                     OR t1.DocumentCreatedDepartmentDSC LIKE '%BWP%'
                     OR t1.DocumentCreatedDepartmentDSC LIKE '%BWF%'
                )
            ) t6 ON t1.PatientEncounterID = t6.PatientEncounterID AND
                    (CASE WHEN t2.HospitalDischargeDTS IS NOT NULL AND t2.HospitalAdmitDTS <= t6.ScannedDTS AND
                               t6.ScannedDTS <= t1.StartDTS
                      THEN 1
                     WHEN t2.HospitalDischargeDTS IS NULL AND t2.HospitalAdmitDTS <= t6.ScannedDTS
                       THEN 1
                     ELSE 0
                     END) = 1
  LEFT JOIN (
              SELECT DISTINCT
                t1.PatientEncounterID,
                CASE WHEN t1.MedicationDSC IS NOT NULL
                  THEN 'Y'
                ELSE 'N'
                END AS CurrentMedication,
                t1.OrderDTS
              FROM Epic.Orders.Medication_DFCI t1
                LEFT JOIN Epic.Reference.Department t2 ON t1.PatientLocationID = t2.DepartmentID
              WHERE
                (t2.DepartmentNM LIKE '%BW%'
                 OR t2.DepartmentNM LIKE '%DF%')
            ) t7 ON t1.PatientEncounterID = t7.PatientEncounterID AND
                    (CASE WHEN t2.HospitalDischargeDTS IS NOT NULL AND t2.HospitalAdmitDTS <= t7.OrderDTS AND
                               t7.OrderDTS <= t2.HospitalDischargeDTS
                      THEN 1
                     WHEN t2.HospitalDischargeDTS IS NULL AND t2.HospitalAdmitDTS <= t7.OrderDTS
                       THEN 1
                     ELSE 0
                     END) = 1
  LEFT JOIN (
              SELECT
                t1.PatientEncounterID,
                t1.DateOfServiceDTS AS ServiceDTS,
                t1.InpatientNoteTypeDSC,
                'Y'                 AS HPFlag
              FROM Epic.Clinical.Note_DFCI t1
              WHERE t1.NoteTypeNoAddDSC LIKE '%H&P Note%'
            ) t8 ON t1.PatientEncounterID = t8.PatientEncounterID AND
                    (CASE WHEN t2.HospitalDischargeDTS IS NOT NULL AND t2.HospitalAdmitDTS <= t8.ServiceDTS AND
                               t8.ServiceDTS <= t2.HospitalDischargeDTS
                      THEN 1
                     WHEN t2.HospitalDischargeDTS IS NULL AND t2.HospitalAdmitDTS <= t8.ServiceDTS
                       THEN 1
                     ELSE 0
                     END) = 1
  LEFT JOIN (
              SELECT DISTINCT
                t1.PatientEncounterID,
                t1.DateOfServiceDTS AS ServiceDTS,
                'Y'                 AS OPNoteFlag
              FROM Epic.Clinical.Note_DFCI t1
              WHERE t1.NoteTypeNoAddDSC LIKE '%Procedure Note%'
            ) t9 ON t1.PatientEncounterID = t9.PatientEncounterID AND
                    (CASE WHEN t2.HospitalDischargeDTS IS NOT NULL AND t2.HospitalAdmitDTS <= t9.ServiceDTS AND
                               t9.ServiceDTS <= t2.HospitalDischargeDTS
                      THEN 1
                     WHEN t2.HospitalDischargeDTS IS NULL AND t2.HospitalAdmitDTS <= t9.ServiceDTS
                       THEN 1
                     ELSE 0
                     END) = 1
  LEFT JOIN (
              SELECT DISTINCT
                t2.PatientID,
                CAST(CAST(t1.EntryTimeDTS AS DATE) AS DATETIME) AS EntryDTS,
                CASE WHEN t3.FlowsheetMeasureNM LIKE '%VITAL%'
                  THEN 'Y'
                ELSE 'N' END                                    AS BaselineVitalFlag,
                CASE WHEN t3.FlowsheetMeasureNM LIKE '%AIRWAY%'
                  THEN 'Y'
                ELSE 'N' END                                    AS AirwayFlag,
                CASE WHEN (t3.FlowsheetMeasureNM LIKE '%COMPLICATIONS%' OR t3.FlowsheetMeasureNM LIKE '%ADVERSE%')
                  THEN 'Y'
                ELSE 'N' END                                    AS ComplicationAdverseFlag
              FROM Epic.Clinical.FlowsheetMeasure_DFCI t1
                LEFT JOIN Epic.Clinical.FlowsheetRecordLink_DFCI t2 ON t1.FlowsheetDataID = t2.FlowsheetDataID
                LEFT JOIN Epic.Clinical.FlowsheetGroup_DFCI t3 ON t1.FlowsheetMeasureID = t3.FlowsheetMeasureID
              WHERE t1.IsAcceptedFLG = 'Y' AND t2.PatientID IS NOT NULL
            ) t10 ON t1.PatientID = t10.PatientID AND
                     (CASE WHEN t2.HospitalDischargeDTS IS NOT NULL AND t2.HospitalAdmitDTS <= t10.EntryDTS AND
                                t10.EntryDTS <= t1.StartDTS
                       THEN 1
                      WHEN t2.HospitalDischargeDTS IS NULL AND t2.HospitalAdmitDTS <= t10.EntryDTS
                        THEN 1
                      ELSE 0
                      END) = 1
WHERE
  t1.PatientID IN (
    SELECT a1.PatientID
    FROM Epic.Encounter.PatientEncounterHospital_DFCI a1
    WHERE a1.DepartmentID IN (10030010022, 10030010024, 10030010026)
  ) AND YEAR(t2.HospitalAdmitDTS) >= 2017;
--Inpatient CMS Project
--Add inpatient outpatient indicator
SELECT
  t4.MRN                  AS DFCI_MRN,
  t1.PatientID            AS Patient_ID,
  t1.PatientEncounterID   AS Encounter_ID,
  t2.HospitalAccountID,
  t3.PatientNM            AS PatientName,
  t2.DepartmentDSC        AS Department_Name,
  t2.HospitalAdmitDTS     AS Admission_DTS,
  t2.HospitalDischargeDTS AS Discharge_DTS,
  t1.StartDTS             AS Procedure_Start_DTS,
  t1.EndDTS               AS Procedure_End_DTS,
  t1.ProcedureDSC         AS Procedure_Name,
  t1.CPT                  AS CPT_Name,
  t1.DiagnosisTest,
  t6.ScannedDTS,
  t6.ConsentFlag,
  t8.HPFlag,
  t8.ServiceDTS           AS HP_ServiceDTS,
  t9.OPNoteFlag,
  t9.ServiceDTS           AS OPNote_ServiceDTS,
  t10.BaselineVitalFlag,
  t11.AirwayFlag,
  t12.ComplicationAdverseFlag,
  t10.EntryTimeDTS        AS Vital_EntryDTS,
  t11.EntryTimeDTS        AS Airway_EntryDTS,
  t12.EntryTimeDTS        AS Complication_EntryDTS
FROM (
       SELECT DISTINCT
         tt1.PatientID,
         tt1.PatientEncounterID,
         tt1.OrderDTS,
         tt1.StartDTS,
         tt1.EndDTS,
         tt1.ProcedureCD,
         tt1.ProcedureDSC,
         tt1.CPT,
         tt2.DiagnosisTest
       FROM Epic.Orders.Procedure_DFCI tt1
         LEFT JOIN (SELECT
                      t1.PatientEncounterID,
                      CASE WHEN t1.ProcedureDSC LIKE '%EKG%' OR
                                t1.ProcedureDSC LIKE '%TTE%' OR
                                t1.ProcedureDSC LIKE '%CATHETERIZATION%' OR
                                t1.ProcedureDSC LIKE '%PULMONARY%FUNCTION%TEST%' OR
                                t1.ProcedureDSC LIKE '%XR%CHEST%'
                        THEN 'Y'
                      ELSE 'N' END AS DiagnosisTest
                    FROM Epic.Orders.Procedure_DFCI t1
                   ) tt2 ON tt1.PatientEncounterID = tt2.PatientEncounterID
       WHERE tt1.PatientEncounterID IS NOT NULL
     ) t1
  LEFT JOIN (
              SELECT DISTINCT
                tt1.PatientEncounterID,
                tt1.DepartmentDSC,
                tt1.HospitalAdmitDTS,
                tt1.HospitalDischargeDTS,
                tt1.HospitalAccountID
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
                t1.ScannedDTS,
                t1.PatientEncounterID,
                'Y' AS ConsentFlag
              FROM Epic.Encounter.DocumentInformation_DFCI t1
              WHERE
                t1.DocumentTypeCD = '110017'
            ) t6
    ON t1.PatientEncounterID = t6.PatientEncounterID
  LEFT JOIN (
              SELECT
                t1.PatientEncounterID,
                t1.DateOfServiceDTS AS ServiceDTS,
                t1.InpatientNoteTypeDSC,
                'Y'                 AS HPFlag
              FROM Epic.Clinical.Note_DFCI t1
              WHERE t1.InpatientNoteTypeDSC LIKE '%H&P%'
            ) t8
    ON t1.PatientEncounterID = t8.PatientEncounterID AND CAST(t1.StartDTS AS DATE) = CAST(t8.ServiceDTS AS DATE)
  LEFT JOIN (
              SELECT
                t1.PatientEncounterID,
                t1.DateOfServiceDTS AS ServiceDTS,
                t1.InpatientNoteTypeDSC,
                'Y'                 AS OpNoteFlag
              FROM Epic.Clinical.Note_DFCI t1
              WHERE t1.InpatientNoteTypeDSC LIKE '%Op Note%'
            ) t9
    ON t1.PatientEncounterID = t9.PatientEncounterID AND CAST(t1.StartDTS AS DATE) = CAST(t9.ServiceDTS AS DATE)
  LEFT JOIN (
              SELECT DISTINCT
                t2.PatientID,
                t1.EntryTimeDTS,
                'Y' AS BaselineVitalFlag
              FROM Epic.Clinical.FlowsheetMeasure_DFCI t1
                LEFT JOIN Epic.Clinical.FlowsheetRecordLink_DFCI t2 ON t1.FlowsheetDataID = t2.FlowsheetDataID
                LEFT JOIN Epic.Clinical.FlowsheetGroup_DFCI t3 ON t1.FlowsheetMeasureID = t3.FlowsheetMeasureID
              WHERE t1.IsAcceptedFLG = 'Y' AND t3.FlowsheetMeasureNM LIKE '%VITAL%'
            ) t10 ON t1.PatientID = t10.PatientID AND CAST(t1.StartDTS AS DATE) = CAST(t10.EntryTimeDTS AS DATE)
  LEFT JOIN (
              SELECT DISTINCT
                t2.PatientID,
                t1.EntryTimeDTS,
                'Y' AS AirwayFlag
              FROM Epic.Clinical.FlowsheetMeasure_DFCI t1
                LEFT JOIN Epic.Clinical.FlowsheetRecordLink_DFCI t2 ON t1.FlowsheetDataID = t2.FlowsheetDataID
                LEFT JOIN Epic.Clinical.FlowsheetGroup_DFCI t3 ON t1.FlowsheetMeasureID = t3.FlowsheetMeasureID
              WHERE t1.IsAcceptedFLG = 'Y' AND t3.FlowsheetMeasureNM LIKE '%AIRWAY%'
            ) t11 ON t1.PatientID = t11.PatientID AND CAST(t1.StartDTS AS DATE) = CAST(t11.EntryTimeDTS AS DATE)
  LEFT JOIN (
              SELECT DISTINCT
                t2.PatientID,
                t1.EntryTimeDTS,
                'Y' AS ComplicationAdverseFlag,
                t3.FlowsheetMeasureNM
              FROM Epic.Clinical.FlowsheetMeasure_DFCI t1
                LEFT JOIN Epic.Clinical.FlowsheetRecordLink_DFCI t2 ON t1.FlowsheetDataID = t2.FlowsheetDataID
                LEFT JOIN Epic.Clinical.FlowsheetGroup_DFCI t3 ON t1.FlowsheetMeasureID = t3.FlowsheetMeasureID
              WHERE t1.IsAcceptedFLG = 'Y' AND
                    (t3.FlowsheetMeasureNM LIKE '%COMPLICATIONS%' OR t3.FlowsheetMeasureNM LIKE '%ADVERSE%')
            ) t12 ON t1.PatientID = t12.PatientID AND CAST(t1.StartDTS AS DATE) = CAST(t12.EntryTimeDTS AS DATE)
  LEFT JOIN Finance.HospitalAccountDRG_DFCI t13 ON t2.HospitalAccountID = t13.HospitalAccountID
  LEFT JOIN Reference.DRG t14 ON t13.DRGRecordID = t14.DRGRecordID
WHERE
  t1.PatientID IN (
    SELECT a1.PatientID
    FROM Epic.Encounter.PatientEncounterHospital_DFCI a1
    WHERE a1.DepartmentID IN (10030010022, 10030010024, 10030010026)
  ) AND YEAR(t2.HospitalAdmitDTS) >= 2017;

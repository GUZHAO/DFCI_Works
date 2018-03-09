SELECT
  t3.PT_DFCI_MRN          AS DFCI_MRN,
  t3.PT_BWH_MRN           AS BWH_MRN,
  t1.PT_ID            AS Patient_ID,
  t1.PT_ENC_ID   AS Encounter_ID,
  t3.PT_LAST_NM || t3.PT_FIRST_NM            AS PatientName,
  t1.ORD_MODE_DESCR      AS PatientType,
  t2.DEPT_DESCR        AS Department_Name,
  t2.HOSP_ADMIT_DTTM     AS Admission_DTS,
  t2.HOSP_DISCHG_DTTM AS Discharge_DTS,
  t1.START_DTTM             AS Procedure_Start_DTS,
  t1.END_DTTM               AS Procedure_End_DTS,
  t1.PROC_DESCR         AS Procedure_Name,
  t1.CPT                  AS CPT_Name,
  t3.D,
  t6.ScannedDTS,
  t6.ConsentFormUsed,
  t6.ConsentFlag,
  t7.ContactDTS           AS Curr_MedicationDTS,
  t7.CurrentMedication,
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
       SELECT
         tt1.PT_ID,
         tt1.PT_ENC_ID,
         tt1.ORD_DTTM,
         tt1.START_DTTM,
         tt1.END_DTTM,
         tt1.PROC_DESCR,
         tt1.CPT,
         tt2.ORD_MODE_DESCR
       FROM DART_ODS.ODS_EDW_ORD_PROC tt1
          LEFT JOIN DART_ODS.ODS_EDW_ORD_PROC_03 tt2 ON tt1.ORD_PROC_ID = tt2.ORD_ID
       WHERE tt1.PT_ENC_ID IS NOT NULL
     ) t1
  LEFT JOIN (
              SELECT DISTINCT
                tt1.PT_ENC_ID,
                tt1.DEPT_DESCR,
                tt1.HOSP_ADMIT_DTTM,
                tt1.HOSP_DISCHG_DTTM
              FROM DART_ODS.ODS_EDW_ENC_PT_ENC_HOSP tt1
            ) t2
    ON t1.PT_ENC_ID = t2.PT_ENC_ID
  LEFT JOIN DART_ODS.MV_COBA_PT_ENC t3
    ON t1.PT_ENC_ID = t3.ENC_ID_CSN
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
              SELECT DISTINCT
                t1.PatientEncounterID,
                'Y' AS CurrentMedication,
                t1.ContactDTS
              FROM Epic.Encounter.CurrentMedication_DFCI t1
              WHERE t1.IsActiveFLG = 'Y'
            ) t7
    ON t1.PatientEncounterID = t7.PatientEncounterID AND CAST(t1.StartDTS AS DATE) = CAST(t7.ContactDTS AS DATE)
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
                'Y' AS ComplicationAdverseFlag
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
  ) AND YEAR(t2.HospitalAdmitDTS) >= 2017
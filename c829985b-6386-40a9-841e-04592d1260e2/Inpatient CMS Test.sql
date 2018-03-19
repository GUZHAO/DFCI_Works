SELECT
  t1.PatientID            AS Patient_ID,
  t1.PatientEncounterID   AS Encounter_ID,
  t1.OrderingModeDSC      AS PatientType,
  t2.DepartmentDSC        AS Department_Name,
  t2.HospitalAdmitDTS     AS Admission_DTS,
  t2.HospitalDischargeDTS AS Discharge_DTS,
  t1.StartDTS             AS Procedure_Start_DTS,
  t1.EndDTS               AS Procedure_End_DTS,
  t1.ProcedureDSC         AS Procedure_Name,
  t1.CPT                  AS CPT_Name
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
WHERE
  t1.PatientID IN (
    SELECT a1.PatientID
    FROM Epic.Encounter.PatientEncounterHospital_DFCI a1
    WHERE a1.DepartmentID IN (10030010022, 10030010024, 10030010026)
  ) AND YEAR(t2.HospitalAdmitDTS) >= 2017;

SELECT t1.*
FROM (
       SELECT
         t4.MRN                  AS DFCI_MRN,
         t1.PatientID            AS Patient_ID,
         t1.PatientEncounterID   AS Encounter_ID,
         t3.PatientNM            AS PatientName,
         t3.MRN                  AS DFCI_MRN_Test,
         t6.MRN                  AS BWH_MRN_Test,
         t1.OrderingModeDSC      AS PatientType,
         t2.DepartmentDSC        AS Department_Name,
         t2.HospitalAdmitDTS     AS Admission_DTS,
         t2.HospitalDischargeDTS AS Discharge_DTS,
         t1.StartDTS             AS Procedure_Start_DTS,
         t1.EndDTS               AS Procedure_End_DTS,
         t1.ProcedureDSC         AS Procedure_Name,
         t1.CPT                  AS CPT_Name,
         t5.DiagnosisID
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
                       t1.PatientEncounterID,
                       t1.DiagnosisID
                     FROM Epic.Orders.DiagnosisProcedure_DFCI t1
                   ) t5
           ON t1.PatientEncounterID = t5.PatientEncounterID
         LEFT JOIN Epic.Patient.Patient_BWHDFCI t6
           ON t1.PatientID = t6.PatientID
       WHERE
         t1.PatientID IN (
           SELECT a1.PatientID
           FROM Epic.Encounter.PatientEncounterHospital_DFCI a1
           WHERE a1.DepartmentID IN (10030010022, 10030010024, 10030010026)
         ) AND YEAR(t2.HospitalAdmitDTS) >= 2017
     ) t1
WHERE t1.Department_Name LIKE 'DF%' OR
      t1.Department_Name LIKE 'BWH%';


SELECT
  t3.MRN                  AS DFCI_MRN,
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
  t6.ScannedDTS,
  t6.ConsentFormUsed,
  t6.ConsentFlag
INTO UserWork.DFCICOBA.INPCMS_Test
FROM (
       SELECT DISTINCT
         tt1.PatientID,
         tt1.PatientEncounterID,
         tt1.OrderDTS,
         tt1.StartDTS,
         tt1.EndDTS,
         tt1.ProcedureCD,
         tt1.ProcedureDSC,
         tt1.CPT
       FROM Epic.Orders.Procedure_DFCI tt1
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
              SELECT DISTINCT
                t1.ScannedDTS,

                t1.PatientEncounterID,
                t1.DocumentCreatedDepartmentDSC AS ConsentFormUsed,
                'Y'                             AS ConsentFlag
              FROM Epic.Encounter.DocumentInformation_DFCI t1
              WHERE
                t1.DocumentTypeCD = '110017'
            ) t6
    ON t1.PatientEncounterID = t6.PatientEncounterID
WHERE
  t1.PatientID IN (
    SELECT a1.PatientID
    FROM Epic.Encounter.PatientEncounterHospital_DFCI a1
    WHERE a1.DepartmentID IN (10030010022, 10030010024, 10030010026)
  ) AND YEAR(t2.HospitalAdmitDTS) >= 2017


SELECT DISTINCT
  t1.PatientID,
  t1.MedicationListReviewCSNID,
  CAST(CAST(t1.MedicationListReviewDTS AS DATE) AS DATETIME2) AS MedicationListreviewDate
FROM Clinical.MedicationReviewHistory_DFCI t1
WHERE t1.PatientID = 'Z10000013'

SELECT DISTINCT
  tt1.PatientID,
  tt1.PatientEncounterID,
  tt1.OrderDTS,
  tt1.StartDTS,
  tt1.EndDTS,
  tt1.ProcedureCD,
  tt1.ProcedureDSC,
  tt1.CPT
FROM Epic.Orders.Procedure_DFCI tt1
WHERE tt1.PatientID = 'Z10000013'

--check consult note
             SELECT DISTINCT
                t1.InpatientNoteTypeDSC
              FROM Epic.Clinical.Note_DFCI t1
              WHERE t1.InpatientNoteTypeDSC LIKE '%Consults%'

            SELECT DISTINCT
                t2.PatientID,
                CAST(t1.EntryTimeDTS AS DATE) AS EntryDTS,
                'Y'                           AS ComplicationAdverseFlag,
                t3.FlowsheetMeasureNM
              FROM Epic.Clinical.FlowsheetMeasure_DFCI t1
                LEFT JOIN Epic.Clinical.FlowsheetRecordLink_DFCI t2 ON t1.FlowsheetDataID = t2.FlowsheetDataID
                LEFT JOIN Epic.Clinical.FlowsheetGroup_DFCI t3 ON t1.FlowsheetMeasureID = t3.FlowsheetMeasureID
              WHERE t1.IsAcceptedFLG = 'Y' AND
                    (t3.FlowsheetMeasureNM LIKE '%AN R NPO STATUS%')
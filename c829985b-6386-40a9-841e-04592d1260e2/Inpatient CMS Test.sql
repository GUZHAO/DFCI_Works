SELECT
  t1.PatientID            AS Patient_ID,
  t1.PatientEncounterID   AS Encounter_ID,
  t1.OrderingModeDSC      AS PatientType,
  t1.StartDTS             AS Procedure_Start_DTS,
  t1.EndDTS               AS Procedure_End_DTS,
  t8.HPFlag,
  t8.ServiceDTS           AS HP_ServiceDTS,
  t9.OPNoteFlag,
  t9.ServiceDTS AS OPNote_ServiceDTS
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
              SELECT
                t1.PatientEncounterID,
                t1.DateOfServiceDTS AS ServiceDTS,
                t1.InpatientNoteTypeDSC,
                'Y'                 AS HPFlag
              FROM Epic.Clinical.Note_DFCI t1
              WHERE t1.NoteTypeNoAddDSC LIKE '%H&P Note%'
            ) t8
    ON t1.PatientEncounterID = t8.PatientEncounterID AND CAST(t1.StartDTS AS DATE) = CAST(t8.ServiceDTS AS DATE)
  LEFT JOIN (
         SELECT DISTINCT
           t1.PatientEncounterID,
           t1.DateOfServiceDTS AS ServiceDTS,
           'Y'                 AS OPNoteFlag
         FROM Epic.Clinical.Note_DFCI t1
         WHERE t1.NoteTypeNoAddDSC LIKE '%Procedure Note%'
       ) t9 ON t1.PatientEncounterID = t9.PatientEncounterID AND CAST(t1.StartDTS AS DATE) = CAST(t9.ServiceDTS AS DATE)

WHERE
  t1.PatientID IN (
    SELECT a1.PatientID
    FROM Epic.Encounter.PatientEncounterHospital_DFCI a1
    WHERE a1.DepartmentID IN (10030010022, 10030010024, 10030010026)
  ) AND YEAR(t1.StartDTS) >= 2017
    AND (t8.HPFlag IS NOT NULL OR t9.OPNoteFlag IS NOT NULL);
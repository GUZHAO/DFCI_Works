SELECT
  t1.PatientEncounterID,
  t1.HospitalAccountID,
  t1.PatientEncounterDTS,
  t1.LineNBR
FROM Finance.HospitalAccountPatientEncounter_DFCI t1
WHERE t1.PatientEncounterID = 3183150148
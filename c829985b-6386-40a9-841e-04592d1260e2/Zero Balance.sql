SELECT
  t1.HospitalAccountID,
  t1.HospitalAccountPatientNM,
  t3.MRN,
  t1.DischargeDTS,
  t1.HospitalAccountBaseClassCD,
  t1.HospitalAccountBaseClassDSC,
  t1.DischargeEpicLocationID,
  t6.RevenueLocationNM,
  t1.TotalChargeAMT,
  t1.TotalPaymentAMT,
  t1.TotalAccountBalanceAMT,
  t1.PrimaryPayorID,
  t4.PayorNM,
  t1.PrimaryBenefitPlanID,
  t5.BenefitPlanNM,
  t1.AccountZeroBalanceDTS,
  t1.FinancialClassDSC
FROM Epic.Finance.HospitalAccount_DFCI t1
  LEFT JOIN Epic.Patient.Patient_DFCI t2
    ON t1.PatientID = t2.PatientID
  LEFT JOIN (
              SELECT
                tt1.EDWPatientID,
                tt1.MRN
              FROM Integration.EMPI.MRN_DFCI tt1
              WHERE tt1.StatusCD = 'A'
            ) t3
    ON t2.EDWPatientID = t3.EDWPatientID
  LEFT JOIN Epic.Reference.Payor t4 ON t1.PrimaryPayorID = t4.PayorID
  LEFT JOIN Epic.Reference.BenefitPlan t5 ON t1.PrimaryBenefitPlanID = t5.BenefitPlanID
  LEFT JOIN Epic.Reference.Location t6 ON t1.DischargeEpicLocationID = t6.LocationID
WHERE t1.HospitalAccountID = 6045675494

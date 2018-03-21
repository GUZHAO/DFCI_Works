SELECT
  t1.HospitalAccountID           AS HOSPITAL_ACCOUNT,
  t1.HospitalAccountPatientNM    AS ACCOUNT_NAME,
  --need to double check
  t3.MRN                         AS DFCI_MRN,
  t1.DischargeDTS                AS DISCHARGE_DATE,
  t1.HospitalAccountBaseClassDSC AS ACCOUNT_BASE_CLASS,
  t6.RevenueLocationNM           AS DISCHARGE_LOC,
  t1.TotalChargeAMT              AS TOTAL_CHARGES,
  t1.TotalPaymentAMT             AS TOTAL_PAYMENTS,
  t1.TotalAccountBalanceAMT      AS ACCOUNT_BALANCE,
  t4.PayorNM                     AS PRIMARY_PAYOR,
  t5.BenefitPlanNM               AS PRIMARY_PLAN,
  t1.AccountZeroBalanceDTS       AS ACCT_ZERO_BAL_DT,
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
--   LEFT JOIN (
--               SELECT
--                 s1.HospitalAccountID,
--                 SUM(s1.BilledAMT)
--               FROM Epic.Finance.HospitalTransaction_DFCI s1
--               WHERE s1.FinancialClassCD = '4'
--               GROUP BY s1.HospitalAccountID
--             ) t7 ON t1.HospitalAccountID = t7.HospitalAccountID

SELECT
  s1.HospitalAccountID,
  s1.TransactionID,
  s1.OriginalReversalTransactionID,
  s1.TransactionTypeDSC,
  s1.BilledAMT,
  s1.PayorID,
  t13.PayorNM,
  s1.FinancialClassCD,
  s1.FinancialClassDSC,
  s1.CoinsuranceAMT,
  s1.CopayAMT,
  s1.CostAMT,
  s1.TransactionAMT,
  s1.AllowedAMT,
  s1.DeductibleAMT,
  s1.NoncoveredAMT,
  s1.PaymentNotAllowedAMT,
  s1.TransactionCommentTXT,
  s1.ProcedureDSC,
  s1.EnterprisePaymentTotalAMT,
  s1.PaymentSourceDSC,
  t14.LineNBR,
  t14.TransactionID AS LineTransaction,
  t14.LineLevelAllowedAMT,
  t14.LineLevelAdjustmentAMT,
  t14.LineLevelBilledAMT,
  t14.LineLevelCoinsAMT,
  t14.LineLevelCopayAMT,
  t14.LineLevelPostedAMT,
  t14.LineLevelNonCoveredAMT,
  t14.LineLevelNotAllowedAMT
FROM Epic.Finance.HospitalTransaction_DFCI s1
  LEFT JOIN Epic.Reference.Payor t13 ON s1.PayorID = t13.PayorID
  LEFT JOIN Epic.Finance.HospitalTransactionLineInformation_DFCI t14 ON s1.TransactionID = t14.TransactionID
WHERE s1.HospitalAccountID = 6045675494

SELECT *
FROM [Epic].[Finance].[CoverageMemberList_DFCI] mem,
  Epic.Finance.Coverage_DFCI cov,
  Epic.Reference.BenefitPlan pl
WHERE PatientID = 'Z11274185'
      AND mem.CoverageID = cov.CoverageID
      AND cov.PlanID = pl.BenefitPlanID


SELECT
  s1.PatientID,
  s1.CoverageID,
  s4.PayorNM,
  s4.LineOfBusinessNM,
  s3.BenefitPlanNM
  FROM Epic.Finance.CoverageMemberList_DFCI s1
    LEFT JOIN Epic.Finance.Coverage_DFCI s2 ON s1.CoverageID = s2.CoverageID
    LEFT JOIN Epic.Reference.BenefitPlan s3 ON s2.PayorID = s3.PayorID
    LEFT JOIN Epic.Finance.CoveragePayorPlan_DFCI s4 ON s1.CoverageID = s4.CoverageID
WHERE s1.PatientID = 'Z11274185'


SELECT
  t1.*
  FROM Epic.Finance.HospitalTransactionLineInformation_DFCI t1
WHERE t1.HospitalAccountID = 6045675494

/*-------------------------------------------------------------*/
/* Example are based on :
   [calendar year 2017,
    calendar month 12,
    primary target CPT Code 99205]
   Examples are billing provider based.
   However if certain examples are not available for this frame*/
/*-------------------------------------------------------------*/

--Example of Reversed transaction
--{Physician Name: "CAMPOS, SUSANA M"}
SELECT
  t1.TRANSACT_ID,
  t1.CPT,
  t1.HOSP_ACCT_ID,
  t1.PT_ENC_ID,
  t1.ORIG_REVRSE_TRANSACT_ID,
  t1.ORIG_LATE_CHG_COR_TRANSACT_ID,
  t1.ORIG_LATE_CHG_CRED_TRANSACT_ID,
  t1.POST_DTTM,
  t1.SVC_DTTM,
  t1.TRANSACT_CNT,
  t1.TRANSACT_AMT,
  t1.HOSP_ACCT_CLS_DESCR,
  t1.BILL_PROV_ID,
  t2.PROV_NM,
  t3.PT_ID,
  t1.DEPT_DESCR
FROM dart_ods.ods_edw_fin_hosp_transact t1
  LEFT JOIN dart_ods.MV_COBA_PROV t2 ON t1.BILL_PROV_ID = t2.PROV_ID
  LEFT JOIN MV_COBA_PT_ENC t3 ON t1.PT_ENC_ID = t3.ENC_ID_CSN
WHERE t1.BILL_PROV_ID = '1000057'
      AND t1.CPT = '99205'
      AND EXTRACT(YEAR FROM t1.SVC_DTTM) = 2017
      AND EXTRACT(MONTH FROM t1.SVC_DTTM) = 12;

--Example of Late Charge Correction to a Different CPT Code (99203)
--{Physician Name: "KABRAJI, SHEHERYAR K"}
SELECT
  t1.TRANSACT_ID,
  t1.CPT,
  t1.HOSP_ACCT_ID,
  t1.PT_ENC_ID,
  t1.ORIG_REVRSE_TRANSACT_ID,
  t1.ORIG_LATE_CHG_COR_TRANSACT_ID,
  t1.ORIG_LATE_CHG_CRED_TRANSACT_ID,
  t1.POST_DTTM,
  t1.SVC_DTTM,
  t1.TRANSACT_CNT,
  t1.TRANSACT_AMT,
  t1.HOSP_ACCT_CLS_DESCR,
  t1.BILL_PROV_ID,
  t2.PROV_NM,
  t3.PT_ID,
  t1.DEPT_DESCR
FROM dart_ods.ods_edw_fin_hosp_transact t1
  LEFT JOIN dart_ods.MV_COBA_PROV t2 ON t1.BILL_PROV_ID = t2.PROV_ID
  LEFT JOIN MV_COBA_PT_ENC t3 ON t1.PT_ENC_ID = t3.ENC_ID_CSN
WHERE t1.BILL_PROV_ID = '1011934'
      AND t1.CPT = '99205'
      AND EXTRACT(YEAR FROM t1.SVC_DTTM) = 2017
      AND EXTRACT(MONTH FROM t1.SVC_DTTM) = 12
      OR t1.TRANSACT_ID = '327820335';

--Example of Provider has both Inpatient and Outpatient Activities on the Same Service Date
--{Physician Name: "NAYAK, LAKSHMI"}
SELECT
  t1.TRANSACT_ID,
  t1.CPT,
  t1.HOSP_ACCT_ID,
  t1.PT_ENC_ID,
  t1.ORIG_REVRSE_TRANSACT_ID,
  t1.ORIG_LATE_CHG_COR_TRANSACT_ID,
  t1.ORIG_LATE_CHG_CRED_TRANSACT_ID,
  t1.POST_DTTM,
  t1.SVC_DTTM,
  t1.TRANSACT_CNT,
  t1.TRANSACT_AMT,
  t1.HOSP_ACCT_CLS_DESCR,
  t1.BILL_PROV_ID,
  t2.PROV_NM,
  t3.PT_ID,
  t1.DEPT_DESCR
FROM dart_ods.ods_edw_fin_hosp_transact t1
  LEFT JOIN dart_ods.MV_COBA_PROV t2 ON t1.BILL_PROV_ID = t2.PROV_ID
  LEFT JOIN MV_COBA_PT_ENC t3 ON t1.PT_ENC_ID = t3.ENC_ID_CSN
WHERE t1.BILL_PROV_ID = '1012901'
      AND t1.CPT = '99205'
      AND EXTRACT(YEAR FROM t1.SVC_DTTM) = 2017
      AND EXTRACT(MONTH FROM t1.SVC_DTTM) = 12;

--Can't match [HAR, CSN] = [6068107092,3180756547] on Inpatient Part
SELECT
  t1.PT_ENC_ID,
  t1.HOSP_ACCT_ID,
  t1.ADT_PT_CLS_DESCR,
  t1.HOSP_ADMIT_DTTM,
  t1.HOSP_DISCHG_DTTM,
  t1.BILL_ATTNDG_PROV_ID
FROM dart_ods.ODS_EDW_ENC_PT_ENC_HOSP t1
WHERE t1.HOSP_ACCT_ID = 6068107092;

--Can match [HAR, CSN] = [6068107092,3180756547] on Outpatient Part
SELECT
  t1.PT_ENC_ID,
  t1.HOSP_ACCT_ID,
  t1.ENC_TYP_DESCR,
  t1.HOSP_ADMIT_DTTM,
  t1.HOSP_DISCHG_DTTM
FROM dart_ods.ODS_EDW_ENC_PT_ENC t1
WHERE t1.PT_ENC_ID = 3180756547;

--Example of When Reverse_ID, Late_Charge_Corr_ID and Late_Charge_Credit are not enough to identify the service quantity
SELECT
  t1.TRANSACT_ID,
  t1.CPT,
  t1.HOSP_ACCT_ID,
  t1.PT_ENC_ID,
  t1.ORIG_REVRSE_TRANSACT_ID,
  t1.ORIG_LATE_CHG_COR_TRANSACT_ID,
  t1.ORIG_LATE_CHG_CRED_TRANSACT_ID,
  t1.POST_DTTM,
  t1.SVC_DTTM,
  t1.TRANSACT_CNT,
  t1.TRANSACT_AMT,
  t1.HOSP_ACCT_CLS_DESCR,
  t1.BILL_PROV_ID,
  t2.PROV_NM,
  t3.PT_ID,
  t1.DEPT_DESCR
FROM
  dart_ods.ods_edw_fin_hosp_transact t1
  LEFT JOIN dart_ods.MV_COBA_PROV t2 ON t1.BILL_PROV_ID = t2.PROV_ID
  LEFT JOIN MV_COBA_PT_ENC t3 ON t1.PT_ENC_ID = t3.ENC_ID_CSN
WHERE t1.BILL_PROV_ID = '1014799'
      AND t1.CPT = '99205'
      AND EXTRACT(YEAR FROM t1.SVC_DTTM) = 2017
      AND EXTRACT(MONTH FROM t1.SVC_DTTM) = 12;

--Provider had inpatient visit at the same day for the same patient
SELECT t1.*
FROM dartedm.f_patient_service@dartprd t1
  LEFT JOIN dartedm.D_PROV@dartprd t2 ON t1.PROV_DIM_SEQ = t2.PROV_DIM_SEQ
  LEFT JOIN dartedm.D_PROC@dartprd t3 ON t1.PROC_DIM_SEQ = t3.PROC_DIM_SEQ
  LEFT JOIN dartedm.D_Patient@dartprd t4 ON t1.PATIENT_DIM_SEQ = t4.PATIENT_DIM_SEQ
WHERE t2.EPIC_PROV_ID = '1014799'
      AND t4.EPIC_PATIENT_ID = 'Z16257931'
      AND SERVICE_DT_DIM_SEQ BETWEEN 20171201 AND 20171231;

--Example of Outpatient Activity has been corrected to Inpatient Activity
--{Physician Name: "HSHIEH, TAMMY T", Type: "External"}
SELECT
  t1.TRANSACT_ID,
  t1.CPT,
  t1.HOSP_ACCT_ID,
  t1.PT_ENC_ID,
  t1.ORIG_REVRSE_TRANSACT_ID,
  t1.ORIG_LATE_CHG_COR_TRANSACT_ID,
  t1.ORIG_LATE_CHG_CRED_TRANSACT_ID,
  t1.POST_DTTM,
  t1.SVC_DTTM,
  t1.TRANSACT_CNT,
  t1.TRANSACT_AMT,
  t1.HOSP_ACCT_CLS_DESCR,
  t1.BILL_PROV_ID,
  t2.PROV_NM,
  t2.PROV_TYPE_DESCR,
  t2.PROV_STATUS_CD,
  t2.PROV_DX_TYPE_DV,
  t2.PROV_INT_EXT_IND_DV,
  t3.PT_ID,
  t1.DEPT_DESCR
FROM
  dart_ods.ods_edw_fin_hosp_transact t1
  LEFT JOIN dart_ods.MV_COBA_PROV t2 ON t1.BILL_PROV_ID = t2.PROV_ID
  LEFT JOIN MV_COBA_PT_ENC t3 ON t1.PT_ENC_ID = t3.ENC_ID_CSN
WHERE t1.BILL_PROV_ID = '1014497'
      AND t1.CPT = '99205'
      AND EXTRACT(YEAR FROM t1.SVC_DTTM) = 2017
      AND EXTRACT(MONTH FROM t1.SVC_DTTM) = 12;

SELECT t1.*
FROM dartedm.f_patient_service@dartprd t1
  LEFT JOIN dartedm.D_PROV@dartprd t2 ON t1.PROV_DIM_SEQ = t2.PROV_DIM_SEQ
  LEFT JOIN dartedm.D_PROC@dartprd t3 ON t1.PROC_DIM_SEQ = t3.PROC_DIM_SEQ
  LEFT JOIN dartedm.D_Patient@dartprd t4 ON t1.PATIENT_DIM_SEQ = t4.PATIENT_DIM_SEQ
WHERE t2.EPIC_PROV_ID = '1014497'
      AND t4.EPIC_PATIENT_ID IN ('Z9851016', 'Z12848136')
      AND SERVICE_DT_DIM_SEQ BETWEEN 20171201 AND 20171231;

--Example of Billing Amount was Charged Wrong
--This example doesn't have a billing provider available.
SELECT
  t1.TRANSACT_ID,
  t1.CPT,
  t1.PROC_ID,
  t1.HOSP_ACCT_ID,
  t1.PT_ENC_ID,
  t1.ORIG_REVRSE_TRANSACT_ID,
  t1.ORIG_LATE_CHG_COR_TRANSACT_ID,
  t1.ORIG_LATE_CHG_CRED_TRANSACT_ID,
  t1.POST_DTTM,
  t1.SVC_DTTM,
  t1.TRANSACT_CNT,
  t1.TRANSACT_AMT,
  t1.HOSP_ACCT_CLS_DESCR,
  t1.BILL_PROV_ID,
  t1.DEPT_DESCR
FROM dart_ods.ods_edw_fin_hosp_transact t1
WHERE t1.PT_ENC_ID = 3076070427;
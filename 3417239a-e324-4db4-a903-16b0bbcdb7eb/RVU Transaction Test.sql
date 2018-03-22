--RUV Outpatient Post-Epic
SELECT
  TO_CHAR(t1.transact_id)  AS transaction_id,
  t12.ORIG_REVRSE_TRANSACT_ID,
  t13.ORIG_LATE_CHG_COR_TRANSACT_ID,
  t14.ORIG_LATE_CHG_CRED_TRANSACT_ID,
  'Outpatient'             AS patienttypeind,
  t1.cpt                   AS cpt_id,
  t4.cpt_cd_descr          AS cpt_nm,
  t1.bill_prov_id          AS billprov_id,
  t11.opr_id               AS billprov_phsid,
  t5.prov_nm               AS billprov_nm,
  t5.prov_type_descr       AS billprov_tp,
  t5.prov_dx_grp_dv        AS diseasecenter,
  t5.prov_dx_site_dv       AS site,
  t5.PROV_INT_EXT_IND_DV   AS int_ext_flag,
  CASE WHEN t12.ORIG_REVRSE_TRANSACT_ID IS NOT NULL
    THEN 0
  WHEN t14.ORIG_LATE_CHG_CRED_TRANSACT_ID IS NOT NULL AND t13.ORIG_LATE_CHG_COR_TRANSACT_ID IS NULL
    THEN 0
  WHEN t14.ORIG_LATE_CHG_CRED_TRANSACT_ID IS NOT NULL AND t13.ORIG_LATE_CHG_COR_TRANSACT_ID IS NOT NULL
    THEN 1
  ELSE 1 END               AS servicequantity,
  CASE WHEN t12.ORIG_REVRSE_TRANSACT_ID IS NOT NULL
    THEN 0
  WHEN t14.ORIG_LATE_CHG_CRED_TRANSACT_ID IS NOT NULL AND t13.ORIG_LATE_CHG_COR_TRANSACT_ID IS NULL
    THEN 0
  WHEN t14.ORIG_LATE_CHG_CRED_TRANSACT_ID IS NOT NULL AND t13.ORIG_LATE_CHG_COR_TRANSACT_ID IS NOT NULL
    THEN t1.TRANSACT_CNT
  ELSE t1.TRANSACT_CNT END AS transactionquantity,
  t10.rvu,
  t11.distrib_pct          AS cfte,
  t1.svc_dttm              AS service_dt,
  t2.pt_dfci_mrn           AS dfci_mrn,
  t2.pt_bwh_mrn            AS bwh_mrn,
  CASE WHEN t3.pt_last_nm IS NOT NULL
    THEN t3.pt_last_nm || ',' || t3.pt_first_nm || ' ' || t3.pt_middle_nm
  ELSE NULL
  END                      AS patient_nm,
  t6.super_prov_id         AS supervisingprov_id,
  t7.prov_nm               AS supervisingprov_nm,
  t1.dept_descr            AS dept_nm,
  t8.place_of_svc_nm       AS place_of_svc_nm,
  t1.proc_id,
  t9.proc_cd,
  t9.proc_nm
FROM
  dart_ods.ods_edw_fin_hosp_transact t1
  LEFT JOIN dart_adm.ds_cpt_adj@dartprd t12 ON t1.proc_id = t12.proc_cd
  LEFT JOIN dart_ods.mv_coba_pt_enc t2 ON t1.pt_enc_id = t2.enc_id_csn
  LEFT JOIN dart_ods.mv_coba_pt t3 ON t2.pt_id = t3.pt_id
  LEFT JOIN dartedm.d_cpt_cd@dartprd t4 ON t1.cpt = t4.cpt_cd
  LEFT JOIN dart_ods.mv_coba_prov t5 ON t1.bill_prov_id = t5.prov_id
  LEFT JOIN dart_ods.ods_edw_enc_pt_enc_02 t6 ON t1.pt_enc_id = t6.pt_enc_id
  LEFT JOIN dart_ods.mv_coba_prov t7 ON t6.super_prov_id = t7.prov_id
  LEFT JOIN dart_ods.ods_edw_ref_place_of_svc t8 ON t1.place_of_svc_id = t8.place_of_svc_id
  LEFT JOIN dart_ods.ods_edw_ref_proc t9 ON t1.PROC_ID = t9.PROC_ID
  LEFT JOIN (
              SELECT DISTINCT
                t1.rvu,
                t2.cpt_cd,
                t1.calendar_dim_seq
              FROM
                dartedm.f_cpt_measure@dartprd t1
                LEFT JOIN dartedm.d_cpt_cd@dartprd t2 ON t1.cpt_dim_seq = t2.cpt_dim_seq
              WHERE
                t1.rvu IS NOT NULL
            ) t10 ON
                    CASE
                    WHEN t1.proc_id = t12.proc_cd
                      THEN t12.cpt_cd
                    ELSE t1.cpt
                    END
                    = t10.cpt_cd
                    AND
                    EXTRACT(YEAR FROM t1.svc_dttm) = to_number(substr(
                                                                   t10.calendar_dim_seq,
                                                                   1,
                                                                   4
                                                               ))
  LEFT JOIN (
              SELECT
                prov.epic_prov_id,
                cal.academic_yr,
                login.opr_id,
                round(
                    SUM(hrs.std_hrs_alloc * alloc.distrib_pct / 100 / yr_days.no_of_days) * 100,
                    3
                ) distrib_pct
              FROM
                dartedm.f_empl_alloc_detail@dartprd alloc
                LEFT JOIN dartedm.f_empl_std_hrs_alloc@dartprd hrs ON (
                hrs.empl_dim_seq = alloc.empl_dim_seq
                AND
                hrs.alloc_dt_dim_seq = alloc.alloc_dt_dim_seq
                )
                LEFT JOIN dartedm.d_calendar@dartprd cal ON cal.calendar_dim_seq = alloc.alloc_dt_dim_seq
                LEFT JOIN dartedm.d_empl@dartprd emp ON emp.empl_dim_seq = alloc.empl_dim_seq
                LEFT JOIN dartadm.user_login@dartprd login ON login.empl_id = emp.empl_id
                JOIN dartedm.d_prov@dartprd prov ON prov.phs_id = login.opr_id
                LEFT JOIN (
                            SELECT
                              cal_sub.academic_yr,
                              COUNT(DISTINCT cal_sub.calendar_dt) no_of_days
                            FROM
                              dartedm.d_calendar@dartprd cal_sub
                            GROUP BY
                              cal_sub.academic_yr
                          ) yr_days ON yr_days.academic_yr = cal.academic_yr
              WHERE
                alloc.active_ind = 'A'
              GROUP BY
                cal.academic_yr,
                prov.epic_prov_id,
                login.opr_id
              ORDER BY prov.epic_prov_id
            ) t11 ON
                    t1.bill_prov_id = t11.epic_prov_id
                    AND
                    EXTRACT(YEAR FROM t1.svc_dttm) = t11.academic_yr
  LEFT JOIN
  (SELECT
     t1.ORIG_REVRSE_TRANSACT_ID,
     t1.CPT
   FROM dart_ods.ods_edw_fin_hosp_transact t1
   WHERE t1.ORIG_REVRSE_TRANSACT_ID IS NOT NULL
  ) t12 ON t1.TRANSACT_ID = t12.ORIG_REVRSE_TRANSACT_ID AND t1.CPT = t12.CPT
  LEFT JOIN
  (SELECT
     t1.ORIG_LATE_CHG_COR_TRANSACT_ID,
     t1.CPT
   FROM dart_ods.ods_edw_fin_hosp_transact t1
   WHERE t1.ORIG_LATE_CHG_COR_TRANSACT_ID IS NOT NULL
  ) t13 ON t1.TRANSACT_ID = t13.ORIG_LATE_CHG_COR_TRANSACT_ID AND t1.CPT = t13.CPT
  LEFT JOIN
  (SELECT
     t1.ORIG_LATE_CHG_CRED_TRANSACT_ID,
     t1.CPT
   FROM dart_ods.ods_edw_fin_hosp_transact t1
   WHERE t1.ORIG_LATE_CHG_CRED_TRANSACT_ID IS NOT NULL
  ) t14 ON t1.TRANSACT_ID = t14.ORIG_LATE_CHG_CRED_TRANSACT_ID AND t1.CPT = t14.CPT
WHERE
  t1.TRANSACT_ID IS NOT NULL
  AND t1.ORIG_REVRSE_TRANSACT_ID IS NULL
  AND t1.ORIG_LATE_CHG_COR_TRANSACT_ID IS NULL
  AND t1.ORIG_LATE_CHG_CRED_TRANSACT_ID IS NULL;

--Example of Late Charge Correction to a Different CPT Code
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
WHERE t1.BILL_PROV_ID = '1011934'
      AND t1.CPT = '99205'
      AND EXTRACT(YEAR FROM t1.SVC_DTTM) = 2017
      AND EXTRACT(MONTH FROM t1.SVC_DTTM) = 12
      OR t1.TRANSACT_ID = '327820335';

--Example of Provider has both Inpatient and Outpatient Activities
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
WHERE t1.BILL_PROV_ID = '1014497'
      AND t1.CPT = '99205'
      AND EXTRACT(YEAR FROM t1.SVC_DTTM) = 2017
      AND EXTRACT(MONTH FROM t1.SVC_DTTM) = 12;






SELECT t1.BILL_ATTNDG_PROV_ID
FROM dart_ods.ODS_EDW_ENC_PT_ENC_HOSP t1
WHERE t1.PT_ENC_ID = 3183150148;
SELECT t1.*
FROM dart_ODS.MV_COBA_PROV t1
WHERE t1.PROV_ID = '1014497';
SELECT t1.*
FROM dart_ods.ODS_EDW_ENC_PT_ENC t1
WHERE t1.PT_ENC_ID = 3183150148;

--Testing Provider distribution
SELECT
  prov.epic_prov_id,
  cal.academic_yr,
  cal.ACADEMIC_PERIOD,
  login.opr_id,
  hrs.std_hrs_alloc,
  alloc.*,
  yr_days.no_of_days
FROM
  dartedm.f_empl_alloc_detail@dartprd alloc
  LEFT JOIN dartedm.f_empl_std_hrs_alloc@dartprd hrs ON (
  hrs.empl_dim_seq = alloc.empl_dim_seq
  AND
  hrs.alloc_dt_dim_seq = alloc.alloc_dt_dim_seq
  )
  LEFT JOIN dartedm.d_calendar@dartprd cal ON cal.calendar_dim_seq = alloc.alloc_dt_dim_seq
  LEFT JOIN dartedm.d_empl@dartprd emp ON emp.empl_dim_seq = alloc.empl_dim_seq
  LEFT JOIN dartadm.user_login@dartprd login ON login.empl_id = emp.empl_id
  JOIN dartedm.d_prov@dartprd prov ON prov.phs_id = login.opr_id
  LEFT JOIN (
              SELECT
                cal_sub.academic_yr,
                COUNT(DISTINCT cal_sub.calendar_dt) no_of_days
              FROM
                dartedm.d_calendar@dartprd cal_sub
              GROUP BY
                cal_sub.academic_yr
            ) yr_days ON yr_days.academic_yr = cal.academic_yr
WHERE
  alloc.active_ind = 'A' AND prov.epic_prov_id = '1003022' AND cal.academic_yr = 2018 AND cal.ACADEMIC_PERIOD = 6
ORDER BY prov.epic_prov_id
-----------------------------------------------------------------------------------------------
SELECT
  t1.BEG_MTH_DIM_SEQ,
  t2.EPIC_PROV_ID,
  t2.PROV_NM,
  t2.PROV_TYPE_DESCR,
  t2.DISEASE_GRP_DESCR,
  t2.DISEASE_SUBGRP_DESCR,
  t3.PROV_NM AS SUPER_PROV,
  t4.PROC_CD,
  t4.PROC_NM,
  t4.CPT_CD,
  t5.CPT_CD_DESCR,
  t11.distrib_pct,
  t1.TOT_SERVICE_QTY,
  t1.TOT_WORK_RVU_AMT
FROM dartedm.F_MTHLY_PROV_SERVICE_RVU@dartprd t1
  LEFT JOIN dartedm.D_PROV@dartprd t2 ON t1.PROV_DIM_SEQ = t2.PROV_DIM_SEQ
  LEFT JOIN dartedm.D_PROV@dartprd t3 ON t1.SUPER_PROV_DIM_SEQ = t3.PROV_DIM_SEQ
  LEFT JOIN dartedm.D_PROC@dartprd t4 ON t1.PROC_DIM_SEQ = t4.PROC_DIM_SEQ
  LEFT JOIN dartedm.D_CPT_CD@dartprd t5 ON t4.CPT_CD = t5.CPT_CD
  LEFT JOIN (
              SELECT
                prov.epic_prov_id,
                cal.academic_yr,
                login.opr_id,
                round(
                    SUM(hrs.std_hrs_alloc * alloc.distrib_pct / 100 / yr_days.no_of_days) * 100,
                    3
                ) distrib_pct
              FROM
                dartedm.f_empl_alloc_detail@dartprd alloc
                LEFT JOIN dartedm.f_empl_std_hrs_alloc@dartprd hrs ON (
                hrs.empl_dim_seq = alloc.empl_dim_seq
                AND
                hrs.alloc_dt_dim_seq = alloc.alloc_dt_dim_seq
                )
                LEFT JOIN dartedm.d_calendar@dartprd cal ON cal.calendar_dim_seq = alloc.alloc_dt_dim_seq
                LEFT JOIN dartedm.d_empl@dartprd emp ON emp.empl_dim_seq = alloc.empl_dim_seq
                LEFT JOIN dartadm.user_login@dartprd login ON login.empl_id = emp.empl_id
                JOIN dartedm.d_prov@dartprd prov ON prov.phs_id = login.opr_id
                LEFT JOIN (
                            SELECT
                              cal_sub.academic_yr,
                              COUNT(DISTINCT cal_sub.calendar_dt) no_of_days
                            FROM
                              dartedm.d_calendar@dartprd cal_sub
                            GROUP BY
                              cal_sub.academic_yr
                          ) yr_days ON yr_days.academic_yr = cal.academic_yr
              WHERE
                alloc.active_ind = 'A'
              GROUP BY
                cal.academic_yr,
                prov.epic_prov_id,
                login.opr_id
              ORDER BY prov.epic_prov_id
            ) t11 ON
                    t2.EPIC_PROV_ID = t11.epic_prov_id
                    AND
                    FLOOR(t1.BEG_MTH_DIM_SEQ / 10000) = t11.academic_yr
WHERE FLOOR(t1.BEG_MTH_DIM_SEQ / 10000) = 2017;
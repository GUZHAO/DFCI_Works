--RUV Outpatient Post-Epic
SELECT
  TO_CHAR(t1.transact_id) AS transaction_id,
  'Outpatient'            AS patienttypeind,
  t1.cpt                  AS cpt_id,
  t4.cpt_cd_descr         AS cpt_nm,
  t1.bill_prov_id         AS billprov_id,
  t11.opr_id              AS billprov_phsid,
  t5.prov_nm              AS billprov_nm,
  t5.prov_type_descr      AS billprov_tp,
  t5.prov_dx_grp_dv       AS diseasecenter,
  t5.prov_dx_site_dv      AS site,
  t5.PROV_INT_EXT_IND_DV  AS int_ext_flag,
  CASE WHEN t12.ORIG_REVRSE_TRANSACT_ID IS NOT NULL OR t1.ORIG_REVRSE_TRANSACT_ID IS NOT NULL
    THEN 0
  WHEN t13.ORIG_LATE_CHG_CRED_TRANSACT_ID IS NOT NULL OR t1.ORIG_LATE_CHG_CRED_TRANSACT_ID IS NOT NULL
    THEN 0
  WHEN t1.HOSP_ACCT_CLS_DESCR = 'INPATIENT'
    THEN 0
  WHEN t14.EPIC_PATIENT_ID IS NOT NULL
    THEN 0
  ELSE 1 END              AS Service_Qty,
  t10.rvu,
  t11.distrib_pct         AS cfte,
  t1.svc_dttm             AS service_dt,
  t2.pt_dfci_mrn          AS dfci_mrn,
  t2.pt_bwh_mrn           AS bwh_mrn,
  CASE WHEN t2.pt_last_nm IS NOT NULL
    THEN t2.pt_last_nm || ',' || t2.pt_first_nm
  ELSE NULL
  END                     AS patient_nm,
  t6.super_prov_id        AS supervisingprov_id,
  t7.prov_nm              AS supervisingprov_nm,
  t1.DEPT_ID,
  t1.dept_descr           AS dept_nm,
  t8.place_of_svc_nm      AS place_of_svc_nm,
  t1.proc_id,
  t9.proc_cd,
  t9.proc_nm
FROM dart_ods.ods_edw_fin_hosp_transact t1
  LEFT JOIN dart_adm.ds_cpt_adj@dartprd t12 ON t1.proc_id = t12.proc_cd
  LEFT JOIN dart_ods.mv_coba_pt_enc t2 ON t1.pt_enc_id = t2.enc_id_csn
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
                    CASE WHEN t1.proc_id = t12.proc_cd
                      THEN t12.cpt_cd
                    ELSE t1.cpt
                    END
                    = t10.cpt_cd
                    AND
                    EXTRACT(YEAR FROM t1.svc_dttm) = to_number(substr(t10.calendar_dim_seq, 1, 4))
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
            ) t11 ON t1.bill_prov_id = t11.epic_prov_id AND EXTRACT(YEAR FROM t1.svc_dttm) = t11.academic_yr
  LEFT JOIN (SELECT t1.ORIG_REVRSE_TRANSACT_ID
             FROM dart_ods.ods_edw_fin_hosp_transact t1
            ) t12 ON t1.TRANSACT_ID = t12.ORIG_REVRSE_TRANSACT_ID
  LEFT JOIN (SELECT t1.ORIG_LATE_CHG_CRED_TRANSACT_ID
             FROM dart_ods.ods_edw_fin_hosp_transact t1
            ) t13 ON t1.TRANSACT_ID = t13.ORIG_LATE_CHG_CRED_TRANSACT_ID
  LEFT JOIN (SELECT DISTINCT
               t1.ACCT_CLASS_NM,
               t1.SERVICE_DT_DIM_SEQ,
               t5.CALENDAR_DT,
               t1.TXN_TYPE_NM,
               t2.EPIC_PROV_ID,
               t4.EPIC_PATIENT_ID
             FROM dartedm.f_patient_service@dartprd t1
               LEFT JOIN dartedm.D_PROV@dartprd t2 ON t1.PROV_DIM_SEQ = t2.PROV_DIM_SEQ
               LEFT JOIN dartedm.D_Patient@dartprd t4 ON t1.PATIENT_DIM_SEQ = t4.PATIENT_DIM_SEQ
               LEFT JOIN dartedm.D_CALENDAR@dartprd t5 ON t1.SERVICE_DT_DIM_SEQ = t5.CALENDAR_DIM_SEQ
             WHERE t1.TXN_TYPE_NM = 'CHARGE' AND t1.ACCT_CLASS_NM = 'INPATIENT' AND t1.SERVICE_DT_DIM_SEQ > '20150530'
            ) t14
    ON t1.BILL_PROV_ID = t14.EPIC_PROV_ID AND t1.SVC_DTTM = t14.CALENDAR_DT AND t2.PT_ID = t14.EPIC_PATIENT_ID
WHERE t1.BILL_PROV_ID IS NOT NULL AND t2.PT_ID IS NOT NULL;

-----------------------------------------------------------------------------------------------
SELECT *
FROM
  (SELECT
     t1.TRANSACT_ID,
     t1.PAY_SRC_DESCR,
     t1.TRANSACT_SRC_DESCR,
     CASE WHEN t12.ORIG_REVRSE_TRANSACT_ID IS NOT NULL OR t1.ORIG_REVRSE_TRANSACT_ID IS NOT NULL
       THEN 0
     WHEN t13.ORIG_LATE_CHG_CRED_TRANSACT_ID IS NOT NULL OR t1.ORIG_LATE_CHG_CRED_TRANSACT_ID IS NOT NULL
       THEN 0
     WHEN t1.HOSP_ACCT_CLS_DESCR = 'INPATIENT'
       THEN 0
     WHEN t14.EPIC_PATIENT_ID IS NOT NULL
       THEN 0
     ELSE 1 END      AS Service_Qty,
     t1.PROC_ID,
     t18.PROC_NM,
     t1.CPT,
     CASE WHEN t2.PROV_TYPE_DESCR <> 'PHYSICIAN' AND t1.PROC_ID = t15.PROC_CD
       THEN CPT_CD
     ELSE t1.CPT END AS CPT_CD,
     t1.HOSP_ACCT_ID,
     t1.PT_ENC_ID,
     t1.ORIG_REVRSE_TRANSACT_ID,
     t1.ORIG_LATE_CHG_COR_TRANSACT_ID,
     t1.ORIG_LATE_CHG_CRED_TRANSACT_ID,
     t1.POST_DTTM,
     t1.SVC_DTTM,
     t1.TRANSACT_CNT,
     t1.TRANSACT_AMT,
     CASE WHEN t1.HOSP_ACCT_CLS_DESCR IN ('OUTPATIENT', 'SPEECH THERAPY SERIES', 'POST PROCEDURE RECOVERY', 'HOSPICE')
       THEN 'O'
     WHEN t1.HOSP_ACCT_CLS_DESCR IN ('OBSERVATION', 'ED OBSERVATION', 'EMERGENCY')
       THEN 'I'
     END             AS INPAT_OUTPAT_IND,
     t1.BILL_PROV_ID,
     t1.PERFORM_PROV_ID,
     t2.PROV_NM,
     t2.PROV_TYPE_DESCR,
     t2.PROV_STATUS_CD,
     t2.PROV_DX_TYPE_DV,
     t2.PROV_INT_EXT_IND_DV,
     t3.PT_ID,
     t3.ENC_STATUS_DESCR,
     t1.DEPT_DESCR,
     t17.PLACE_OF_SVC_NM,
     t16.SUPER_PROV_ID
   FROM
     dart_ods.ods_edw_fin_hosp_transact t1
     LEFT JOIN dart_ods.MV_COBA_PROV t2 ON t1.BILL_PROV_ID = t2.PROV_ID
     LEFT JOIN DART_ODS.MV_COBA_PT_ENC t3 ON t1.PT_ENC_ID = t3.ENC_ID_CSN
     LEFT JOIN (SELECT t1.ORIG_REVRSE_TRANSACT_ID
                FROM dart_ods.ods_edw_fin_hosp_transact t1
               ) t12 ON t1.TRANSACT_ID = t12.ORIG_REVRSE_TRANSACT_ID
     LEFT JOIN (SELECT t1.ORIG_LATE_CHG_CRED_TRANSACT_ID
                FROM dart_ods.ods_edw_fin_hosp_transact t1
               ) t13 ON t1.TRANSACT_ID = t13.ORIG_LATE_CHG_CRED_TRANSACT_ID
     LEFT JOIN (SELECT DISTINCT
                  t1.ACCT_CLASS_NM,
                  t1.SERVICE_DT_DIM_SEQ,
                  t5.CALENDAR_DT,
                  t1.TXN_TYPE_NM,
                  t2.EPIC_PROV_ID,
                  t4.EPIC_PATIENT_ID
                FROM dartedm.f_patient_service@dartprd t1
                  LEFT JOIN dartedm.D_PROV@dartprd t2 ON t1.PROV_DIM_SEQ = t2.PROV_DIM_SEQ
                  LEFT JOIN dartedm.D_Patient@dartprd t4 ON t1.PATIENT_DIM_SEQ = t4.PATIENT_DIM_SEQ
                  LEFT JOIN dartedm.D_CALENDAR@dartprd t5 ON t1.SERVICE_DT_DIM_SEQ = t5.CALENDAR_DIM_SEQ
                WHERE t1.TXN_TYPE_NM = 'CHARGE' AND t1.ACCT_CLASS_NM = 'INPATIENT' AND
                      t1.SERVICE_DT_DIM_SEQ > '20150530'
               ) t14
       ON t1.BILL_PROV_ID = t14.EPIC_PROV_ID AND t1.SVC_DTTM = t14.CALENDAR_DT AND t3.PT_ID = t14.EPIC_PATIENT_ID
     LEFT JOIN DART_ADM.DS_CPT_ADJ@DARTPRD t15 ON t1.PROC_ID = t15.PROC_CD
     LEFT JOIN DART_ODS.ODS_EDW_ENC_PT_ENC_02 t16 ON t1.PT_ENC_ID = t16.PT_ENC_ID
     LEFT JOIN dart_ods.ods_edw_ref_place_of_svc t17 ON t1.PLACE_OF_SVC_ID = t17.PLACE_OF_SVC_ID
     LEFT JOIN DART_ODS.ODS_EDW_REF_PROC t18 ON t1.PROC_ID = t18.PROC_ID
  ) t1
WHERE t1.BILL_PROV_ID = '1003022' AND t1.CPT_CD = '99213'
      AND EXTRACT(YEAR FROM t1.SVC_DTTM) = 2017
      AND EXTRACT(MONTH FROM t1.SVC_DTTM) = 12;

----------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------
SELECT DISTINCT
  t1.PROC_ID,
  t1.PROC_DESCR,
  (CASE WHEN t1.PROC_ID = 372288
    THEN '99203'
   WHEN t1.PROC_ID = 372292
     THEN '99204'
   WHEN t1.PROC_ID = 372298
     THEN '99205'
   WHEN t1.PROC_ID = 372304
     THEN '99211'
   WHEN t1.PROC_ID = 372322
     THEN '99213'
   WHEN t1.PROC_ID = 372332
     THEN '99214'
   WHEN t1.PROC_ID = 372350
     THEN '99215'
   ELSE t1.CPT END) CPT_CD,
  t1.CPT
FROM
  dart_ods.ods_edw_fin_hosp_transact t1
  LEFT JOIN dart_ods.MV_COBA_PROV t2 ON t1.BILL_PROV_ID = t2.PROV_ID
WHERE t1.PROC_ID IN (372288, 372292, 372298, 372304, 372322, 372332, 372350);

-----------------------------------------------------------------------------------------------------------------------

SELECT
  t1.*,
  t5.CALENDAR_DT,
  t1.TXN_TYPE_NM,
  t2.EPIC_PROV_ID,
  t4.EPIC_PATIENT_ID
FROM dartedm.f_patient_service@dartprd t1
  LEFT JOIN dartedm.D_PROV@dartprd t2 ON t1.PROV_DIM_SEQ = t2.PROV_DIM_SEQ
  LEFT JOIN dartedm.D_PROC@dartprd t3 ON t1.PROC_DIM_SEQ = t3.PROC_DIM_SEQ
  LEFT JOIN dartedm.D_Patient@dartprd t4 ON t1.PATIENT_DIM_SEQ = t4.PATIENT_DIM_SEQ
  LEFT JOIN dartedm.D_CALENDAR@dartprd t5 ON t1.SERVICE_DT_DIM_SEQ = t5.CALENDAR_DIM_SEQ
WHERE
  t2.EPIC_PROV_ID = '1005955'
  --   AND t1.TXN_TYPE_NM = 'CHARGE' AND t1.ACCT_CLASS_NM = 'INPATIENT'
  AND t1.SERVICE_DT_DIM_SEQ > '20171201' AND t1.SERVICE_DT_DIM_SEQ < '20171231' AND t3.CPT_CD = '99205'


-----------------------------------------------------------------------------------------------------------------------
--D_SERVICE_TXN Creation
SELECT
  ODS_EDW_FIN_HOSP_TRANSACT.TRANSACT_ID,
  ODS_EDW_FIN_HOSP_TRANSACT.DEPT_ID,
  ODS_EDW_FIN_HOSP_TRANSACT.CHG_MOD_LIST_TXT,
  REGEXP_SUBSTR(ODS_EDW_FIN_HOSP_TRANSACT.CHG_MOD_LIST_TXT, '[^,]+', 1, 1) AS CPT_MOD_1,
  REGEXP_SUBSTR(ODS_EDW_FIN_HOSP_TRANSACT.CHG_MOD_LIST_TXT, '[^,]+', 1, 2) AS CPT_MOD_2,
  REGEXP_SUBSTR(ODS_EDW_FIN_HOSP_TRANSACT.CHG_MOD_LIST_TXT, '[^,]+', 1, 3) AS CPT_MOD_3,
  ODS_EDW_FIN_HOSP_TRANSACT.POST_BATCH_NBR,
  ODS_EDW_FIN_HOSP_TRANSACT.UB_REVENUE_CD_ID,
  ODS_EDW_FIN_HOSP_TRANSACT.REVENUE_LOC_ID,
  ODS_EDW_FIN_HOSP_TRANSACT.POST_DTTM
FROM
  DART_ODS.ODS_EDW_FIN_HOSP_TRANSACT;

--F_PATIENT_SERVICE Creation
  SELECT
    t1.*,
    CASE WHEN t1.HOSP_ACCT_CLS_DESCR IN ('OUTPATIENT', 'SPEECH THERAPY SERIES', 'POST PROCEDURE RECOVERY', 'HOSPICE')
      THEN 'O'
    WHEN t1.HOSP_ACCT_CLS_DESCR IN ('OBSERVATION', 'ED OBSERVATION', 'EMERGENCY')
      THEN 'I'
    WHEN t1.HOSP_ACCT_CLS_DESCR = 'INPATIENT' AND t1.ODS_CREATE_SRC_CD = 'PBT'
      THEN 'O'
    ELSE 'I' END AS INPAT_OUTPAT_IND,
    t2.REVENUE_LOC_NM,
    t3.RECORD_INST_CD,
    t4.INST_DIM_SEQ
  FROM (
         SELECT
           ODS_EDW_FIN_HOSP_TRANSACT.TRANSACT_ID,
           ODS_EDW_FIN_HOSP_TRANSACT.HOSP_ACCT_ID,
           ODS_EDW_FIN_HOSP_TRANSACT.HOSP_ACCT_CLS_DESCR,
           ODS_EDW_FIN_HOSP_TRANSACT.BILL_PROV_ID,
           ODS_EDW_FIN_HOSP_TRANSACT.DEPT_ID,
           ODS_EDW_FIN_HOSP_TRANSACT.PT_ENC_ID,
           ODS_EDW_FIN_HOSP_TRANSACT.PERFORM_PROV_ID,
           ODS_EDW_FIN_HOSP_TRANSACT.PROC_ID,
           ODS_EDW_FIN_HOSP_TRANSACT.TRANSACT_CNT,
           ODS_EDW_FIN_HOSP_TRANSACT.REVENUE_LOC_ID,
           ODS_EDW_FIN_HOSP_TRANSACT.SVC_DTTM,
           ODS_EDW_FIN_HOSP_TRANSACT.TRANSACT_AMT,
           ODS_EDW_FIN_HOSP_TRANSACT.TRANSACT_TYP_DESCR,
           ODS_EDW_FIN_HOSP_TRANSACT.ODS_CREATE_SRC_CD,
           ODS_EDW_FIN_HOSP_TRANSACT.ODS_UPD_SRC_CD
         FROM
           DART_ODS.ODS_EDW_FIN_HOSP_TRANSACT
         UNION
         SELECT
           PBT.TRANSACT_ID,
           NULL          AS HOSP_ACCT_ID,
           'INPATIENT'   AS HOSP_ACCT_CLS_DESCR,
           PBT.BILL_PROV_ID,
           PBT.DEPT_ID,
           PBT.PT_ENC_ID,
           NULL          AS PERFORM_PROV_ID,
           PBT.PROC_ID,
           NULL          AS TRANSACT_CNT,
           PBT.LOC_ID    AS REVENUE_LOC_ID,
           PBT.SVC_DTTM,
           PBT.TRANSACT_AMT,
           PBT.TYP_DESCR AS TRANSACT_TYP_DESCR,
           CASE WHEN PBT.ODS_CREATE_SRC_CD = 'EPC'
             THEN 'PBT'
           ELSE NULL END AS ODS_UPD_SRC_CD,
           CASE WHEN PBT.ODS_UPD_SRC_CD = 'EPC'
             THEN 'PBT'
           ELSE NULL END AS ODS_UPD_SRC_CD
         FROM DART_ODS.ODS_EDW_FIN_PROF_BILL_TRANSACT PBT
         WHERE PBT.TYP_DESCR = 'CHARGE'
       ) t1
    LEFT JOIN DART_ODS.ODS_EDW_REF_LOC t2 ON t1.REVENUE_LOC_ID = t2.LOC_ID
LEFT JOIN DARTEDM.D_CLIN_DEPT@DARTPRD t3 ON t1.DEPT_ID = t3.DEPT_ID
LEFT JOIN DARTEDM.D_INST@DARTPRD t4 ON t3.RECORD_INST_CD = t4.INST_ABBREV







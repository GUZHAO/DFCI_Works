--Adult + Pediatric
--PsychOnc + PalliativeCare
--Inpatient + Outpatient
--Pre-Epic + Post-Epic
--Currently focusing on one month worth of data

/*Adult PsychOnc+Palliative Outpatient Pre-Epic???*/
--Very likely to start on FY2016

/*Adult PsychOnc+Palliative Outpatient Post-Epic*/
SELECT
  TO_CHAR(t1.transact_id) AS transaction_id,
  t1.hosp_acct_cls_descr  AS patienttypeind,
  t1.cpt                  AS cpt_id,
  t4.cpt_cd_descr         AS cpt_nm,
  t1.bill_prov_id         AS billprov_id,
  t11.opr_id              AS billprov_phsid,
  t5.prov_nm              AS billprov_nm,
  t5.prov_type_descr      AS billprov_tp,
  t5.prov_dx_grp_dv       AS diseasecenter,
  t5.prov_dx_site_dv      AS site,
  1                       AS servicequantity,
  t10.rvu,
  NULL                    AS cfte,
  t1.svc_dttm             AS service_dt,
  t2.pt_dfci_mrn          AS dfci_mrn,
  t2.pt_bwh_mrn           AS bwh_mrn,
  CASE
  WHEN t3.pt_last_nm IS NOT NULL
    THEN t3.pt_last_nm
         || ','
         || t3.pt_first_nm
         || ' '
         || t3.pt_middle_nm
  ELSE NULL
  END
                          AS patient_nm,
  t6.super_prov_id        AS supervisingprov_id,
  t7.prov_nm              AS supervisingprov_nm,
  t1.dept_descr           AS dept_nm,
  t8.place_of_svc_nm      AS place_of_svc_nm
--    t1.proc_id
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
  LEFT JOIN dart_ods.ods_edw_ref_svc_area t9 ON t1.svc_area_id = t9.svc_area_id
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
  LEFT JOIN (SELECT
               prov.epic_prov_id,
               login.opr_id
             FROM dartadm.user_login@dartprd login
               JOIN dartedm.d_prov@dartprd prov ON prov.phs_id = login.opr_id
            ) t11 ON
                    t1.bill_prov_id = t11.epic_prov_id
WHERE
  t1.transact_typ_cd = 1
  AND
  t1.post_dttm >= '30-MAY-15'
  AND
  t1.DEPT_DESCR IN ('DF PALLIATIVE CARE', 'DF PSYCH ONC')
  AND EXTRACT(YEAR FROM t1.SVC_DTTM) = 2017
  AND EXTRACT(MONTH FROM t1.SVC_DTTM) = 5

UNION

/*Adult PsychOnc+Palliative Inpatient Pre-Epic???*/
--Very likely to start on FY2016

/*Adult PsychOnc+Palliative Inpatient Post-Epic*/--May
SELECT
  TO_CHAR(t1.transact_id) AS transaction_id,
  'Inpatient'             AS patienttypeind,
  t1.cpt_cd               AS cpt_id,
  t6.cpt_cd_descr         AS cpt_nm,
  t1.bill_prov_id         AS billprov_id,
  t11.opr_id              AS billprov_phsid,
  t7.prov_nm              AS billprov_nm,
  t7.prov_type_descr      AS billprov_tp,
  t7.prov_dx_grp_dv       AS diseasecenter,
  t7.prov_dx_site_dv      AS site,
  1                       AS servicequantity,
  t10.rvu,
  NULL                    AS cfte,
  t1.svc_dttm             AS service_dt,
  t5.pt_dfci_mrn          AS dfci_mrn,
  t5.pt_bwh_mrn           AS bwh_mrn,
  CASE
  WHEN t5.pt_last_nm IS NOT NULL
    THEN t5.pt_last_nm
         || ','
         || t5.pt_first_nm
         || ' '
         || t5.pt_middle_nm
  ELSE NULL
  END
                          AS patient_nm,
  t8.super_prov_id        AS supervisingprov_id,
  t9.prov_nm              AS supervisingprov_nm,
  t1.dept_descr           AS dept_nm,
  t3.place_of_svc_nm      AS place_of_svc_nm
--    t1.proc_id
FROM
  dart_ods.ods_edw_fin_prof_bill_transact t1
  LEFT JOIN dart_adm.ds_cpt_adj@dartprd t12 ON t1.proc_id = t12.proc_cd
  LEFT JOIN dart_ods.ods_edw_ref_loc t2 ON t1.loc_id = t2.loc_id
  LEFT JOIN dart_ods.ods_edw_ref_place_of_svc t3 ON t1.place_of_svc_id = t3.place_of_svc_id
  LEFT JOIN dart_ods.ods_edw_ref_svc_area t4 ON t1.svc_area_id = t4.svc_area_id
  LEFT JOIN dart_ods.mv_coba_pt t5 ON t1.pt_id = t5.pt_id
  LEFT JOIN dartedm.d_cpt_cd@dartprd t6 ON t1.cpt_cd = t6.cpt_cd
  LEFT JOIN dart_ods.mv_coba_prov t7 ON t1.bill_prov_id = t7.prov_id
  LEFT JOIN dart_ods.ods_edw_enc_pt_enc_02 t8 ON t1.pt_enc_id = t8.pt_enc_id
  LEFT JOIN dart_ods.mv_coba_prov t9 ON t8.super_prov_id = t9.prov_id
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
                    ELSE t1.cpt_cd
                    END
                    = t10.cpt_cd
                    AND
                    EXTRACT(YEAR FROM t1.svc_dttm) = to_number(substr(
                                                                   t10.calendar_dim_seq,
                                                                   1,
                                                                   4
                                                               ))
  LEFT JOIN (SELECT
               prov.epic_prov_id,
               login.opr_id
             FROM dartadm.user_login@dartprd login
               JOIN dartedm.d_prov@dartprd prov ON prov.phs_id = login.opr_id
            ) t11 ON
                    t1.bill_prov_id = t11.epic_prov_id
WHERE
  t1.DEPT_DESCR IN ('DF PALLIATIVE CARE', 'DF PSYCH ONC')
  AND EXTRACT(YEAR FROM t1.SVC_DTTM) = 2017
  AND EXTRACT(MONTH FROM t1.SVC_DTTM) = 5;

/*Pediatric Palliative + PsychOnc Inpatient*/
--Children File

/*Pediatric Palliative Outpatient???*/
--Epic department
SELECT DISTINCT t1.ENC_DEPT_DESCR
FROM dart_ods.MV_COBA_PT_ENC t1
WHERE t1.ENC_DEPT_DESCR LIKE '%PALLIATIVE%';

/*Pediatric PsychOnc Outpatient*/
--Qview

/*cFTE*/
--Ellen's File
SELECT
  t1.PROV_ID,
  t1.PROV_NM,
  t1.PROV_PRIM_DEPT_ID,
  t1.PROV_PRIM_DEPT_DESCR,
  t1.PROV_DX_GRP_DV
FROM DART_ODS.MV_COBA_PROV t1
WHERE t1.PROV_NM LIKE '%MURPHY%';

SELECT
  a1.birth_dttm,
  a1.MRN,
  a1.PT_ID,
  a1.PT_NM,
  a1.zip_cd,
  a2.appt_dttm,
  a2.enc_epic_prov_id,
  a2.pt_id,
  a2.pt_enc_id,
  a3.prov_nm,
  a3.prov_ID,
  a4.disease_grp_descr
FROM dart_ods.ods_edw_pt_pt a1
  LEFT JOIN dart_ods.ods_edw_enc_pt_enc a2 ON a1.pt_id = a2.pt_id
  LEFT JOIN dart_ods.MV_COBA_PROV a3 ON a2.enc_epic_prov_ID = a3.prov_id
  LEFT JOIN dart_ods.MV_COBA_DS_PROV a4 ON a3.PROV_ID = a4.EPIC_PROV_ID;


SELECT DISTINCT
  t1.rvu,
  t2.cpt_cd,
  t1.calendar_dim_seq
FROM
  dartedm.f_cpt_measure@dartprd t1
  LEFT JOIN dartedm.d_cpt_cd@dartprd t2 ON t1.cpt_dim_seq = t2.cpt_dim_seq
WHERE
  t1.rvu IS NOT NULL AND t2.cpt_cd LIKE '9%' AND t1.calendar_dim_seq=20170101

------------------------------------------------------------------------------------------------------------------------
/*Take Inpatient Part Out*/
SELECT
    TO_CHAR(t1.transact_id) AS transaction_id,
    'Inpatient' AS patienttypeind,
    t1.cpt_cd AS cpt_id,
    t6.cpt_cd_descr AS cpt_nm,
    t1.bill_prov_id AS billprov_id,
    t11.opr_id AS billprov_phsid,
    t7.prov_nm AS billprov_nm,
    t7.prov_type_descr AS billprov_tp,
    t7.prov_dx_grp_dv AS diseasecenter,
    t7.prov_dx_site_dv AS site,
    1 AS servicequantity,
    t10.rvu,
    t11.distrib_pct AS cfte,
    t1.svc_dttm AS service_dt,
    t5.pt_dfci_mrn AS dfci_mrn,
    t5.pt_bwh_mrn AS bwh_mrn,
        CASE
            WHEN t5.pt_last_nm IS NOT NULL THEN t5.pt_last_nm
             || ','
             || t5.pt_first_nm
             || ' '
             || t5.pt_middle_nm
            ELSE NULL
        END
    AS patient_nm,
    t8.super_prov_id AS supervisingprov_id,
    t9.prov_nm AS supervisingprov_nm,
    t1.dept_descr AS dept_nm,
    t3.place_of_svc_nm AS place_of_svc_nm
--    t1.proc_id
FROM
    dart_ods.ods_edw_fin_prof_bill_transact t1
    LEFT JOIN dart_adm.ds_cpt_adj@dartprd t12 ON t1.proc_id = t12.proc_cd
    LEFT JOIN dart_ods.ods_edw_ref_loc t2 ON t1.loc_id = t2.loc_id
    LEFT JOIN dart_ods.ods_edw_ref_place_of_svc t3 ON t1.place_of_svc_id = t3.place_of_svc_id
    LEFT JOIN dart_ods.ods_edw_ref_svc_area t4 ON t1.svc_area_id = t4.svc_area_id
    LEFT JOIN dart_ods.mv_coba_pt t5 ON t1.pt_id = t5.pt_id
    LEFT JOIN dartedm.d_cpt_cd@dartprd t6 ON t1.cpt_cd = t6.cpt_cd
    LEFT JOIN dart_ods.mv_coba_prov t7 ON t1.bill_prov_id = t7.prov_id
    LEFT JOIN dart_ods.ods_edw_enc_pt_enc_02 t8 ON t1.pt_enc_id = t8.pt_enc_id
    LEFT JOIN dart_ods.mv_coba_prov t9 ON t8.super_prov_id = t9.prov_id
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
                WHEN t1.proc_id = t12.proc_cd  THEN t12.cpt_cd
                ELSE t1.cpt_cd
            END
        = t10.cpt_cd
    AND
        EXTRACT(YEAR FROM t1.svc_dttm) = to_number(substr(
            t10.calendar_dim_seq,
            1,
            4
        ) )
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
WHERE extract(YEAR FROM t1.svc_dttm)>2016 AND t1.bill_prov_id IN ('1000057', '1000073', '1000082')
--------------------------------------------------------------------------------------------------------
/*Take Outpatient Part Out*/
SELECT
    TO_CHAR(t1.transact_id) AS transaction_id,
    t1.hosp_acct_cls_descr AS patienttypeind,
    t1.cpt AS cpt_id,
    t4.cpt_cd_descr AS cpt_nm,
    t1.bill_prov_id AS billprov_id,
    t11.opr_id AS billprov_phsid,
    t5.prov_nm AS billprov_nm,
    t5.prov_type_descr AS billprov_tp,
    t5.prov_dx_grp_dv AS diseasecenter,
    t5.prov_dx_site_dv AS site,
    1 AS servicequantity,
    t10.rvu,
    t11.distrib_pct AS cfte,
    t1.svc_dttm AS service_dt,
    t2.pt_dfci_mrn AS dfci_mrn,
    t2.pt_bwh_mrn AS bwh_mrn,
        CASE
            WHEN t3.pt_last_nm IS NOT NULL THEN t3.pt_last_nm
             || ','
             || t3.pt_first_nm
             || ' '
             || t3.pt_middle_nm
            ELSE NULL
        END
    AS patient_nm,
    t6.super_prov_id AS supervisingprov_id,
    t7.prov_nm AS supervisingprov_nm,
    t1.dept_descr AS dept_nm,
    t8.place_of_svc_nm AS place_of_svc_nm
--    t1.proc_id
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
    LEFT JOIN dart_ods.ods_edw_ref_svc_area t9 ON t1.svc_area_id = t9.svc_area_id
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
                WHEN t1.proc_id = t12.proc_cd   THEN t12.cpt_cd
                ELSE t1.cpt
            END
        = t10.cpt_cd
    AND
        EXTRACT(YEAR FROM t1.svc_dttm) = to_number(substr(
            t10.calendar_dim_seq,
            1,
            4
        ) )
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
WHERE
        t1.transact_typ_cd = 1
    AND
        t1.post_dttm >= '30-MAY-15'
    AND extract(YEAR FROM t1.svc_dttm)>2016
    AND t1.bill_prov_id in ('1000134', '1000057', '1000493')
------------------------------------------------------------------------------------------------------------------------
/*Check Outpatient data*/
SELECT
  t1.TRANSACT_ID,
  t1.HOSP_ACCT_ID,
  t1.PT_ENC_ID,
  t1.SVC_DTTM,
  t1.POST_DTTM,
  t1.PROC_ID,
  t1.CPT,
  t1.TRANSACT_CNT,
  t1.HOSP_ACCT_CLS_DESCR,
  t1.BILL_PROV_ID,
  t1.DEPT_DESCR,
  t1.ORIG_REVRSE_TRANSACT_ID,
  t1.CHG_MOD_LIST_TXT,
  t1.ORIG_PRICE_AMT,
  t1.TRANSACT_AMT,
  t1.FIN_CLS_DESCR,
  t1.DFT_CHG_TRAN_UB_REVENUE_CD_ID
FROM dart_ods.ods_edw_fin_hosp_transact t1
WHERE t1.bill_prov_id IN ('1006711') /*t1.DEPT_DESCR LIKE '%PALLIATIVE%'*/
      AND t1.transact_typ_cd = 1
      AND t1.post_dttm >= '30-MAY-15'
      AND extract(YEAR FROM t1.svc_dttm) = 2017
      AND extract(MONTH FROM t1.svc_dttm) = 9
      AND extract(DAY FROM t1.svc_dttm) = 1
ORDER BY t1.TRANSACT_ID


SELECT t1.*
--   t1.TRANSACT_ID,
--   t1.PT_ENC_ID,
--   t1.SVC_DTTM,
--   t1.POST_DTTM,
--   t1.PROC_ID,
--   t1.CPT_CD,
--   t1.TYP_DESCR,
--   t1.BILL_PROV_ID,
--   t1.DEPT_DESCR,
--   t1.TRANSACT_AMT,
--   t1.ORIG_FIN_CLS_DESCR
FROM dart_ods.ods_edw_fin_prof_bill_transact t1
WHERE t1.bill_prov_id='1101449'    /*t1.DEPT_DESCR LIKE '%PALLIATIVE%'*/
      AND t1.post_dttm >= '30-MAY-15'
      AND extract(YEAR FROM t1.svc_dttm) = 2017
      AND extract(MONTH FROM t1.svc_dttm) = 9
--      AND extract(DAY FROM t1.svc_dttm) = 1
ORDER BY t1.TRANSACT_ID
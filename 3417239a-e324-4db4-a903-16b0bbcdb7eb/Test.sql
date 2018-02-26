--RVU
/*Inpatient Post-Epic*/
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
  t7.prov_int_ext_ind_dv  AS int_ext_flag,
  CASE WHEN t1.TRANSACT_AMT >= 0
    THEN 1
  ELSE -1 END             AS servicequantity,
  t10.rvu,
  t11.distrib_pct         AS cfte,
  t1.svc_dttm             AS service_dt,
  t5.pt_dfci_mrn          AS dfci_mrn,
  t5.pt_bwh_mrn           AS bwh_mrn,
  CASE WHEN t5.pt_last_nm IS NOT NULL
    THEN t5.pt_last_nm || ',' || t5.pt_first_nm || ' ' || t5.pt_middle_nm
  ELSE NULL END           AS patient_nm,
  t8.super_prov_id        AS supervisingprov_id,
  t9.prov_nm              AS supervisingprov_nm,
  t1.dept_descr           AS dept_nm,
  t3.place_of_svc_nm      AS place_of_svc_nm,
  t4.proc_cd,
  t4.proc_nm
FROM dart_ods.ods_edw_fin_prof_bill_transact t1
  LEFT JOIN dart_adm.ds_cpt_adj@dartprd t12 ON t1.proc_id = t12.proc_cd
  LEFT JOIN dart_ods.ods_edw_ref_place_of_svc t3 ON t1.place_of_svc_id = t3.place_of_svc_id
  LEFT JOIN dart_ods.ODS_EDW_REF_PROC t4 ON t1.PROC_ID = t4.PROC_ID
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
              FROM dartedm.f_cpt_measure@dartprd t1
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
            ) t11 ON
                    t1.bill_prov_id = t11.epic_prov_id
                    AND
                    EXTRACT(YEAR FROM t1.svc_dttm) = t11.academic_yr
  LEFT JOIN dart_ods.ODS_EDW_REF_PROC t12 ON t1.proc_id = t12.proc_id
WHERE t1.BILL_PROV_ID IS NOT NULL

UNION
/*Outpatient Post-Epic*/

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
  CASE WHEN t1.ORIG_REVRSE_TRANSACT_ID IS NOT NULL
    THEN -1
  ELSE 1 END              AS servicequantity,
  t10.rvu,
  t11.distrib_pct         AS cfte,
  t1.svc_dttm             AS service_dt,
  t2.pt_dfci_mrn          AS dfci_mrn,
  t2.pt_bwh_mrn           AS bwh_mrn,
  CASE WHEN t3.pt_last_nm IS NOT NULL
    THEN t3.pt_last_nm || ',' || t3.pt_first_nm || ' ' || t3.pt_middle_nm
  ELSE NULL
  END                     AS patient_nm,
  t6.super_prov_id        AS supervisingprov_id,
  t7.prov_nm              AS supervisingprov_nm,
  t1.dept_descr           AS dept_nm,
  t8.place_of_svc_nm      AS place_of_svc_nm,
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
WHERE t1.transact_typ_cd = 1
      AND t1.post_dttm >= '30-MAY-15'
      AND t1.TRANSACT_ID NOT IN (
  SELECT DISTINCT t1.ORIG_REVRSE_TRANSACT_ID
  FROM dart_ods.ods_edw_fin_hosp_transact t1
  WHERE t1.ORIG_REVRSE_TRANSACT_ID IS NOT NULL)
      AND t1.ORIG_REVRSE_TRANSACT_ID IS NULL


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
WHERE FLOOR(t1.BEG_MTH_DIM_SEQ / 10000) = 2017
;



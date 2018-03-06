/*Inpatient Pre-Epic*/
SELECT
  t1.txn_id              AS transaction_id,
  'Inpatient'            AS patienttypeind,
  t1.txn_cd              AS cpt_id,
  t2.cpt_cd_descr        AS cpt_nm,
  t6.prov_id             AS billprov_id,
  t7.opr_id              AS billprov_phsid,
  t6.prov_nm             AS billprov_nm,
  t6.prov_type_descr     AS billprov_tp,
  t6.prov_dx_grp_dv      AS diseasecenter,
  t6.prov_dx_site_dv     AS site,
  t6.prov_int_ext_ind_dv AS int_ext_flag,
  1                      AS servicequantity,
  t5.rvu,
  t7.distrib_pct         AS cfte,
  t1.service_dt          AS service_dt,
  t1.mrn                 AS dfci_mrn,
  t1.alt_mrn             AS bwh_mrn,
  CASE WHEN t3.pt_last_nm IS NOT NULL
    THEN t3.pt_last_nm || ',' || t3.pt_first_nm || ' ' || t3.pt_middle_nm
  ELSE NULL END          AS patient_nm,
  t4.super_prov_id       AS supervisingprov_id,
  t4.prov_nm             AS supervisingprov_nm,
  t1.bill_prov_dept_nm   AS dept_nm,
  t1.alt_mrn_site_nm     AS place_of_svc_nm,
  NULL                   AS proc_cd,
  NULL                   AS proc_nm
FROM dartods.ods_hart_charge_data t1
  LEFT JOIN dartedm.d_cpt_cd@dartprd t2 ON t1.txn_cd = t2.cpt_cd
  LEFT JOIN dart_ods.mv_coba_pt t3 ON t1.mrn = t3.pt_dfci_mrn
  LEFT JOIN (
              SELECT DISTINCT
                t1.super_prov_id,
                t1.cont_dttm,
                t2.pt_dfci_mrn,
                t3.prov_nm
              FROM
                (
                  SELECT DISTINCT
                    pt_enc_id,
                    super_prov_id,
                    cont_dttm
                  FROM
                    dart_ods.ods_edw_enc_pt_enc_02
                  WHERE
                    super_prov_id IS NOT NULL
                ) t1
                LEFT JOIN dart_ods.mv_coba_pt_enc t2 ON t1.pt_enc_id = t2.enc_id_csn
                LEFT JOIN dart_ods.mv_coba_prov t3 ON t1.super_prov_id = t3.prov_id
            ) t4 ON
                   t1.mrn = t4.pt_dfci_mrn
                   AND
                   t1.service_dt = t4.cont_dttm
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
            ) t5 ON
                   t1.txn_cd = t5.cpt_cd
                   AND
                   EXTRACT(YEAR FROM t1.service_dt) = to_number(substr(
                                                                    t5.calendar_dim_seq,
                                                                    1,
                                                                    4
                                                                ))
  LEFT JOIN dart_ods.mv_coba_prov t6 ON t1.bill_prov_npi = t6.prov_npi_id
  LEFT JOIN (
              SELECT
                prov.epic_prov_id,
                login.opr_id,
                cal.academic_yr,
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
            ) t7 ON
                   t6.prov_id = t7.epic_prov_id
                   AND
                   EXTRACT(YEAR FROM t1.service_dt) = t7.academic_yr

UNION
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
/*Outpatient Pre-Epic*/

SELECT
  dps.txn_id              AS transaction_id,
  fps.acct_class_nm       AS patienttypeind,
  pr.cpt_cd               AS cpt_id,
  cpt1.cpt_cd_descr       AS cpt_nm,
  CASE WHEN bill.epic_prov_id = -1
    THEN NULL
  ELSE bill.epic_prov_id
  END AS billprov_id,
  t11.opr_id              AS billprov_phsid,
  CASE WHEN bill.epic_prov_id = -1
    THEN NULL
  ELSE bill.prov_nm
  END AS billprov_nm,
  bill.prov_type_descr    AS billprov_tp,
  bill.disease_grp_descr  AS diseasecenter,
  t12.prov_dx_site_dv     AS site,
  t12.prov_int_ext_ind_dv AS int_ext_flag,
  fps.service_qty         AS servicequantity,
  cpt.rvu,
  t11.distrib_pct         AS cfte,
  cal.calendar_dt         AS service_dt,
  pt.dfci_mrn             AS dfci_mrn,
  pt.bwh_mrn              AS bwh_mrn,
  CASE WHEN pt.last_nm IS NOT NULL
    THEN pt.last_nm || ',' || pt.first_nm || ' ' || pt.middle_nm
  END AS patient_nm,
  CASE WHEN sup.epic_prov_id = -1
    THEN NULL
  ELSE sup.epic_prov_id
  END AS supervisingprov_id,
  CASE WHEN sup.epic_prov_id = -1
    THEN NULL
  ELSE sup.prov_nm
  END AS supervisingprov_nm,
  dept.clin_dept_nm       AS dept_nm,
  dept.location_nm        AS place_of_svc_nm,
  pr.proc_cd,
  pr.proc_nm
FROM
  dartedm.d_service_txn@dartprd dps
  JOIN dartedm.f_patient_service@dartprd fps ON dps.service_txn_dim_seq = fps.service_txn_dim_seq
  JOIN dartedm.d_calendar@dartprd cal ON fps.service_dt_dim_seq = cal.calendar_dim_seq
  LEFT JOIN dartedm.d_patient@dartprd pt ON fps.patient_dim_seq = pt.patient_dim_seq
  JOIN dartedm.d_prov@dartprd bill ON fps.billing_prov_dim_seq = bill.prov_dim_seq
  LEFT JOIN dartedm.d_prov@dartprd prov ON fps.prov_dim_seq = prov.prov_dim_seq
  LEFT JOIN dartedm.d_prov@dartprd sup ON fps.super_prov_dim_seq = sup.prov_dim_seq
  LEFT JOIN dartedm.d_proc@dartprd pr ON fps.proc_dim_seq = pr.proc_dim_seq
  LEFT JOIN dartedm.d_clin_dept@dartprd dept ON fps.clin_dept_dim_seq = dept.clin_dept_dim_seq
  LEFT JOIN (
              SELECT
                rvu,
                cpt_cd,
                calendar_dim_seq
              FROM
                dartedm.f_cpt_measure@dartprd fm
                JOIN dartedm.d_cpt_cd@dartprd cpt ON fm.cpt_dim_seq = cpt.cpt_dim_seq
              WHERE
                rvu IS NOT NULL
              GROUP BY
                rvu,
                cpt_cd,
                calendar_dim_seq
            ) cpt ON
                    pr.cpt_cd = cpt.cpt_cd
                    AND
                    substr(
                        TO_CHAR(fps.service_dt_dim_seq),
                        1,
                        4
                    ) = substr(
                        TO_CHAR(cpt.calendar_dim_seq),
                        1,
                        4
                    )
  LEFT JOIN dartedm.d_cpt_cd@dartprd cpt1 ON pr.cpt_cd = cpt1.cpt_cd
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
                    bill.epic_prov_id = t11.epic_prov_id
                    AND
                    EXTRACT(YEAR FROM cal.calendar_dt) = t11.academic_yr
  LEFT JOIN dart_ods.mv_coba_prov t12 ON prov.epic_prov_id = t12.prov_id
WHERE
  fps.txn_type_nm = 'CHARGE'
  AND
  fps.acct_class_nm = 'OUTPATIENT'
  AND
  fps.dart_create_src_cd = 'COR' -- LEGACY CHARGES

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
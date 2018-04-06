--F_MTHLY_PROV_SERVICE_RVU Testing
SELECT
  t1.PROC_DIM_SEQ,
  t1.BEG_MTH_DIM_SEQ,
  t1.TOT_SERVICE_QTY,
  t1.PROC_DIM_SEQ,
  t2.EPIC_PROV_ID,
  t2.PROV_NM,
  t3.CPT_CD
FROM dartedm.F_MTHLY_PROV_SERVICE_RVU t1
  LEFT JOIN dartedm.D_PROV t2 ON t1.PROV_DIM_SEQ = t2.PROV_DIM_SEQ
  LEFT JOIN dartedm.D_PROC t3 ON t1.PROC_DIM_SEQ = t3.PROC_DIM_SEQ
WHERE t2.EPIC_PROV_ID = '1014799'
      AND t3.CPT_CD = '99205'
ORDER BY t1.BEG_MTH_DIM_SEQ;

--F_PROV_EFFORT_RVU
SELECT
  t1.*,
  t4.DFCI_MRN
FROM DARTEDM.F_PROV_EFFORT_RVU t1
  LEFT JOIN dartedm.D_PROV t2 ON t1.PROV_DIM_SEQ = t2.PROV_DIM_SEQ
  LEFT JOIN dartedm.D_PROC t3 ON t1.PROC_DIM_SEQ = t3.PROC_DIM_SEQ
  LEFT JOIN dartedm.D_PATIENT t4 ON t1.PATIENT_DIM_SEQ = t4.PATIENT_DIM_SEQ
WHERE t2.EPIC_PROV_ID = '1014799'
      AND t3.CPT_CD = '99205'
      AND SERVICE_DT_DIM_SEQ BETWEEN 20171201 AND 20171231;

--F_PATIENT_SERVICE
SELECT
  t1.*,
  t4.CPT_CD
FROM dartedm.f_patient_service t1
  LEFT JOIN dartedm.D_PROV t2 ON t1.PROV_DIM_SEQ = t2.PROV_DIM_SEQ
  LEFT JOIN dartedm.D_PROC t3 ON t1.PROC_DIM_SEQ = t3.PROC_DIM_SEQ
  LEFT JOIN dartedm.D_PROC t4 ON t1.PROC_DIM_SEQ = t4.PROC_DIM_SEQ
WHERE t2.EPIC_PROV_ID = '1014799'
      --AND t3.CPT_CD = '99205'
      AND SERVICE_DT_DIM_SEQ BETWEEN 20171201 AND 20171231;


--Testing Provider distribution
SELECT
  prov.epic_prov_id,
  cal.CALENDAR_DT,
  login.opr_id,
  hrs.std_hrs_alloc,
  alloc.*,
  yr_days.no_of_days
FROM dartedm.f_empl_alloc_detail@dartprd alloc
  LEFT JOIN dartedm.f_empl_std_hrs_alloc@dartprd hrs ON (
  hrs.empl_dim_seq = alloc.empl_dim_seq AND
  hrs.alloc_dt_dim_seq = alloc.alloc_dt_dim_seq)
  LEFT JOIN dartedm.d_calendar@dartprd cal ON cal.calendar_dim_seq = alloc.alloc_dt_dim_seq
  LEFT JOIN dartedm.d_empl@dartprd emp ON emp.empl_dim_seq = alloc.empl_dim_seq
  LEFT JOIN dartadm.user_login@dartprd login ON login.empl_id = emp.empl_id
  JOIN dartedm.d_prov@dartprd prov ON prov.phs_id = login.opr_id
  LEFT JOIN (
              SELECT
                cal_sub.CALENDAR_YR,
                COUNT(DISTINCT cal_sub.calendar_dt) no_of_days
              FROM
                dartedm.d_calendar@dartprd cal_sub
              GROUP BY
                cal_sub.CALENDAR_YR
            ) yr_days ON yr_days.CALENDAR_YR = cal.CALENDAR_YR
WHERE
  alloc.active_ind = 'A' AND prov.epic_prov_id = '1012901' AND EXTRACT(YEAR FROM cal.CALENDAR_DT) = 2017
-----------------------------------------------------------------------------------------------

SELECT BEG_MTH_DIM_SEQ, DISTRIB_PCT, COUNT(DISTRIB_PCT) AS CNT
FROM (
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
                  cal.CALENDAR_DT,
                  login.opr_id,
                  hrs.std_hrs_alloc,
                  alloc.*,
                  yr_days.no_of_days
                FROM dartedm.f_empl_alloc_detail@dartprd alloc
                  LEFT JOIN dartedm.f_empl_std_hrs_alloc@dartprd hrs ON (
                    hrs.empl_dim_seq = alloc.empl_dim_seq AND
                    hrs.alloc_dt_dim_seq = alloc.alloc_dt_dim_seq)
                  LEFT JOIN dartedm.d_calendar@dartprd cal ON cal.calendar_dim_seq = alloc.alloc_dt_dim_seq
                  LEFT JOIN dartedm.d_empl@dartprd emp ON emp.empl_dim_seq = alloc.empl_dim_seq
                  LEFT JOIN dartadm.user_login@dartprd login ON login.empl_id = emp.empl_id
                  JOIN dartedm.d_prov@dartprd prov ON prov.phs_id = login.opr_id
                  LEFT JOIN (
                              SELECT
                                cal_sub.CALENDAR_YR,
                                COUNT(DISTINCT cal_sub.calendar_dt) no_of_days
                              FROM
                                dartedm.d_calendar@dartprd cal_sub
                              GROUP BY
                                cal_sub.CALENDAR_YR
                            ) yr_days ON yr_days.CALENDAR_YR = cal.CALENDAR_YR
                WHERE
                  alloc.active_ind = 'A' AND prov.epic_prov_id = '1012901' AND EXTRACT(YEAR FROM cal.CALENDAR_DT) = 2017
              ) t11
      ON t2.EPIC_PROV_ID = t11.epic_prov_id AND FLOOR(t1.BEG_MTH_DIM_SEQ / 10000) = EXTRACT(YEAR FROM t11.CALENDAR_DT)
  WHERE FLOOR(t1.BEG_MTH_DIM_SEQ / 10000) = 2017 AND t2.EPIC_PROV_ID = '1012901' AND t4.CPT_CD = '99205' AND DISTRIB_PCT = 55
)
GROUP BY BEG_MTH_DIM_SEQ, DISTRIB_PCT
;

SELECT
  t1.*,
  t3.PROC_NM,
  t3.CPT_CD
  FROM DARTEDM.F_MTHLY_PROV_SERVICE_RVU t1
LEFT JOIN DARTEDM.D_PROV t2 ON t1.PROV_DIM_SEQ = t2.PROV_DIM_SEQ
    LEFT JOIN DARTEDM.D_PROC t3 ON t1.PROC_DIM_SEQ = t3.PROC_DIM_SEQ
WHERE t2.EPIC_PROV_ID = '1011132' AND t1.BEG_MTH_DIM_SEQ = 20171201

/*
1005955
1007862
*/

SELECT
  t1.*,
  t2.PROC_NM
  FROM DART_ADM.DS_CPT_ADJ t1
LEFT JOIN DARTEDM.D_PROC t2 ON t1.PROC_CD = t2.PROC_CD
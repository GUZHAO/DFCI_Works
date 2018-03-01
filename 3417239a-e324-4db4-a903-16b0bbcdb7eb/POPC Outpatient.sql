--POPC Outpatient
SELECT
  t1.PT_ID,
  t10.PT_DFCI_MRN,
  t10.PT_BWH_MRN,
  t1.PT_ENC_ID,
  t1.appt_dttm             AS appt_dts,
  t1.dept_descr            AS department_nm,
  t1.enc_epic_prov_id      AS enc_prov_id,
  t1.cont_dttm             AS contact_dts,
  t1.hosp_admit_dttm,
  t1.hosp_dischg_dttm,
  t1.hosp_admit_typ_descr  AS hosp_admit_tp,
  t6.prov_nm               AS enc_prov_nm,
  t2.molst_ind,
  t3.healthcareproxy_ind,
  t4.opioid_ind,
  t5.laxative_ind,
  t6.prov_dx_grp_dv        AS dis_ctr_nm,
  t11.prov_dx_grp_dv       AS dis_ctr_nm_ref,
  t12.prov_dx_grp_dv       AS dis_ctr_nm_att,
  t7.chaplain_Ind,
  t8.socialworker_Ind,
  t9.pt_death_dt,
  t9.pt_birth_dt,
  t9.pt_race_1_nm,
  t9.PT_ETHNICITY_1_NM,
  t9.pt_gender_nm,
  t9.pt_perm_zip_cd,
  t9.pt_age_dv,
  t10.enc_refer_prov_id,
  t10.ENC_DEPT_DESCR       AS enc_department_nm,
  t10.enc_refer_prov_nm,
  t10.enc_attndg_prov_id,
  t10.enc_attndg_prov_nm,
  t10.enc_loc_nm_dv        AS pt_loc_nm,
  t10.enc_vis_typ_descr    AS visit_ty,
  t10.enc_status_descr,
  t13.CT_PROV_ID           AS PRIMARY_ONCOLOGIST_ID,
  t13.PROV_NM              AS PRIMARY_ONCOLOGIST,
  t13.PROV_DX_GRP_DV       AS PRIMARY_ONC_PRIM_DX_CTR,
  t14.CUSTOM_COLM_02_DESCR AS pt_dis_ctr_nm
FROM dart_ods.ods_edw_enc_pt_enc t1
  LEFT JOIN (
              SELECT
                t1.pt_id,
                1 AS molst_ind
              FROM dart_ods.ods_edw_enc_doc_info t1
              WHERE
                t1.doc_typ_descr IN ('MOLST')
              GROUP BY
                t1.pt_id
            ) t2 ON t1.pt_id = t2.pt_id
  LEFT JOIN (
              SELECT
                t1.pt_id,
                1 AS healthcareproxy_ind
              FROM dart_ods.ods_edw_enc_doc_info t1
              WHERE
                t1.doc_typ_descr IN ('HEALTHCARE PROXY')
              GROUP BY
                t1.pt_id
            ) t3 ON t1.pt_id = t3.pt_id
  LEFT JOIN (
              SELECT
                t1.pt_id,
                1 AS opioid_ind
              FROM dart_ods.ods_edw_ord_med t1
              WHERE
                t1.Med_DESCR LIKE '%MS CONTIN%'
                OR t1.Med_DESCR LIKE '%MORPHINE%'
                OR t1.Med_DESCR LIKE '%OXYCODON%'
                OR t1.Med_DESCR LIKE '%FENTANYL%PATCH%'
                OR t1.Med_DESCR LIKE '%METHADONE%'
                OR t1.Med_DESCR LIKE '%DILAUDID%'
              GROUP BY
                t1.pt_id
            ) t4 ON t1.pt_id = t4.pt_id
  LEFT JOIN (
              SELECT
                t1.pt_id,
                1 AS laxative_ind
              FROM dart_ods.ods_edw_ord_med t1
              WHERE
                t1.Med_DESCR LIKE '%polyethylene glycol%'
                OR t1.Med_DESCR LIKE '%SENNA%'
                OR t1.Med_DESCR LIKE '%COLACE%'
                OR t1.Med_DESCR LIKE '%docusate%'
                OR t1.Med_DESCR LIKE '%MILK OF MAGNESIA%'
                OR t1.Med_DESCR LIKE '%BISACODYL%'
                OR t1.Med_DESCR LIKE '%MAGNESIUM%CITRATE%'
                OR t1.Med_DESCR LIKE '%LACTULOSE%'
              GROUP BY
                t1.pt_id
            ) t5 ON t1.pt_id = t5.pt_id
  LEFT JOIN dart_ods.mv_coba_prov t6 ON t1.enc_epic_prov_id = t6.prov_id
  LEFT JOIN (
              SELECT
                t1.pt_enc_id,
                1 AS chaplain_Ind
              FROM dart_ods.ods_edw_enc_tx_team_prov t1
              WHERE
                t1.role_descr LIKE '%CHAPLAIN%'
              GROUP BY
                t1.pt_enc_id
            ) t7 ON t1.pt_enc_id = t7.pt_enc_id
  LEFT JOIN (
              SELECT
                t1.pt_enc_id,
                1 AS socialworker_Ind
              FROM dart_ods.ods_edw_enc_tx_team_prov t1
              WHERE
                t1.role_descr = 'SOCIAL WORKER'
              GROUP BY
                t1.pt_enc_id
            ) t8 ON t1.pt_enc_id = t8.pt_enc_id
  LEFT JOIN dart_ods.mv_coba_pt t9 ON t1.pt_id = t9.pt_id
  LEFT JOIN dart_ods.mv_coba_pt_enc t10 ON t1.pt_enc_id = t10.enc_id_csn
  LEFT JOIN dart_ods.mv_coba_prov t11 ON t10.enc_refer_prov_id = t11.prov_id
  LEFT JOIN dart_ods.mv_coba_prov t12 ON t10.enc_attndg_prov_id = t12.prov_id
  LEFT JOIN (
              SELECT
                PO.PT_ID,
                PO.CT_PROV_ID,
                MD.PROV_NM,
                MD.PROV_DX_GRP_DV
              FROM
                (
                  SELECT
                    CT.CT_PT_ID     AS PT_ID,
                    MAX(CT_PROV_ID) AS CT_PROV_ID
                  FROM
                    DART_ODS.MV_COBA_PT_CARE_TEAM CT
                  WHERE
                    CT_PROV_ROLE_DESCR = 'PRIMARY ONCOLOGIST'
                    AND CT.CT_PROV_DEL_IND <> 'Y'
                    AND CT.CT_PROV_HX_CMNT_TXT LIKE 'DFCI%' --Will this remove BWH referrals?
                  GROUP BY CT.CT_PT_ID
                ) PO
                LEFT JOIN DART_ODS.MV_COBA_PROV MD ON MD.PROV_ID = PO.CT_PROV_ID

            ) t13 ON t1.pt_id = t13.pt_id
  LEFT JOIN DART_ODS.ODS_EDW_PT_REGISTRY_ADDL t14 ON t1.PT_ID = t14.PT_ID
WHERE
  t1.PT_ID IN (
    SELECT pe.pt_id
    FROM dart_ods.mv_coba_pt_enc pe
    WHERE enc_status_descr IN ('ARRIVED', 'COMPLETED')
          AND pe.enc_loc_nm_dv IN (
      'DANA-FARBER CANCER INSTITUTE LONGWOOD',
      'DANA-FARBER AT ST. ELIZABETH MEDICAL CENTER',
      'DANA-FARBER BWCC AT MILFORD REGIONAL MEDICAL CENTER',
      'DANA-FARBER BWCC SOUTH SHORE CANCER CENTER',
      'DANA-FARBER LONDONDERRY'
    )
  ) AND t1.APPT_DTTM > '01-OCT-15';

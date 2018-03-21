SELECT
  t1.PT_ID,
  t13.PT_DFCI_MRN,
  t13.PT_BWH_MRN,
  t1.PT_ENC_ID,
  t1.appt_dttm            AS appt_dts,
  t1.dept_descr           AS department_nm,
  t1.enc_epic_prov_id     AS enc_prov_id,
  t1.cont_dttm            AS contact_dts,
  t14.event_dttm          AS ed_event_dttm,
  t1.hosp_admit_dttm,
  t1.hosp_dischg_dttm,
  t1.hosp_admit_typ_descr AS hosp_admit_tp,
  t6.prov_nm              AS enc_prov_nm,
  t2.molst_ind,
  --patient level
  t3.healthcareproxy_ind,
  --patient level
  t4.opioid_ind,
  t5.laxative_ind,
  t6.prov_dx_grp_dv       AS dis_ctr_nm,
  t15.prov_dx_grp_dv      AS dis_ctr_nm_ref,
  t16.prov_dx_grp_dv      AS dis_ctr_nm_att,
  t7.chaplain_Ind,
  t8.socialworker_Ind,
  t9.pt_death_dt,
  --patient level
  t9.pt_birth_dt,
  --patient level
  t9.pt_race_1_nm,
  --patient level
  t9.PT_ETHNICITY_1_NM,
  --patient level
  t9.pt_gender_nm,
  --patient level
  t9.pt_perm_zip_cd,
  --patient level
  t9.pt_age_dv,
  --patient level
  t13.enc_refer_prov_id,
  t13.ENC_DEPT_DESCR      AS enc_department_nm,
  t13.enc_refer_prov_nm,
  t13.enc_attndg_prov_id,
  t13.enc_attndg_prov_nm,
  t13.enc_loc_nm_dv       AS pt_loc_nm,
  t13.enc_vis_typ_descr   AS visit_ty,
  t13.enc_status_descr,
  t17.CT_PROV_ID          AS PRIMARY_ONCOLOGIST_ID,
  t17.PROV_NM             AS PRIMARY_ONCOLOGIST,
  t17.PROV_DX_GRP_DV      AS PRIMARY_ONC_PRIM_DX_CTR,
  t18.DISCHG_DISP_DESCR,
  t19.MIN_CREATE_DTTM,
  t19.MIN_CODE_STATUS,
  t19.MAX_CREATE_DTTM,
  t19.MAX_CODE_STATUS,
  t20.ChemoFlag
FROM
  dart_ods.ods_edw_enc_pt_enc t1
  LEFT JOIN (
              SELECT
                pt_id,
                1 AS molst_ind
              FROM
                dart_ods.ods_edw_enc_doc_info
              WHERE
                doc_typ_descr IN (
                  'MOLST'
                )
              GROUP BY
                pt_id,
                1
            ) t2 ON t1.pt_id = t2.pt_id
  LEFT JOIN (
              SELECT
                pt_id,
                1 AS healthcareproxy_ind
              FROM
                dart_ods.ods_edw_enc_doc_info
              WHERE
                doc_typ_descr IN (
                  'HEALTHCARE PROXY'
                )
              GROUP BY
                pt_id,
                1
            ) t3 ON t1.pt_id = t3.pt_id
  LEFT JOIN (
              SELECT DISTINCT
                pt_id,
                1 AS opioid_ind
              FROM
                dart_ods.ods_edw_ord_med
              WHERE
                Med_DESCR LIKE '%MS CONTIN%'
                OR Med_DESCR LIKE '%morphine%'
                OR Med_DESCR LIKE '%OXYCODON%'
                OR Med_DESCR LIKE '%FENTANYL%PATCH%'
                OR Med_DESCR LIKE '%METHADONE%'
                OR Med_DESCR LIKE '%DILAUDID%'
              GROUP BY
                pt_id,
                1
            ) t4 ON t1.pt_id = t4.pt_id
  LEFT JOIN (
              SELECT DISTINCT
                pt_id,
                1 AS laxative_ind
              FROM
                dart_ods.ods_edw_ord_med
              WHERE
                Med_DESCR LIKE '%polyethylene glycol%'
                OR Med_DESCR LIKE '%SENNA%'
                OR Med_DESCR LIKE '%COLACE%'
                OR Med_DESCR LIKE '%docusate%'
                OR Med_DESCR LIKE '%MILK OF MAGNESIA%'
                OR Med_DESCR LIKE '%BISACODYL%'
                OR Med_DESCR LIKE '%MAGNESIUM%CITRATE%'
                OR Med_DESCR LIKE '%LACTULOSE%'
              GROUP BY
                pt_id,
                1
            ) t5 ON t1.pt_id = t5.pt_id
  LEFT JOIN dart_ods.mv_coba_prov t6 ON t1.enc_epic_prov_id = t6.prov_id
  LEFT JOIN (
              SELECT
                pt_enc_id,
                1 AS chaplain_Ind
              FROM
                dart_ods.ods_edw_enc_tx_team_prov
              WHERE
                role_descr LIKE '%CHAPLAIN%'
              GROUP BY
                pt_enc_id,
                role_descr
            ) t7 ON t1.pt_enc_id = t7.pt_enc_id
  LEFT JOIN (
              SELECT
                pt_enc_id,
                1 AS socialworker_Ind
              FROM
                dart_ods.ods_edw_enc_tx_team_prov
              WHERE
                role_descr = 'SOCIAL WORKER'
              GROUP BY
                pt_enc_id,
                role_descr
            ) t8 ON t1.pt_enc_id = t8.pt_enc_id
  LEFT JOIN dart_ods.mv_coba_pt t9 ON t1.pt_id = t9.pt_id
  LEFT JOIN dart_ods.mv_coba_pt_enc t13 ON t1.pt_enc_id = t13.enc_id_csn
  LEFT JOIN (SELECT
               event_dttm,
               pt_id,
               pt_enc_id
             FROM dart_ods.ods_edw_enc_adt
             WHERE pt_cls_cd = '103' AND event_dttm > '01-OCT-2015' AND dept_id = 10030010039 AND
                   adt_event_typ_descr = 'ADMISSION' AND adt_event_subtyp_descr ^= 'CANCELED') t14
    ON t1.pt_enc_id = t14.pt_enc_id
  LEFT JOIN dart_ods.mv_coba_prov t15 ON t13.enc_refer_prov_id = t15.prov_id
  LEFT JOIN dart_ods.mv_coba_prov t16 ON t13.enc_attndg_prov_id = t16.prov_id
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

            ) t17 ON t1.pt_id = t17.pt_id
  LEFT JOIN DART_ODS.ODS_EDW_ENC_PT_ENC_HOSP t18 ON t1.pt_enc_id = t18.pt_enc_id
  LEFT JOIN (
              SELECT
                MAXCS.CSN_ID,
                MINCS.CREATE_INSTANT_DTTM AS MIN_CREATE_DTTM,
                MINCS.CAT_DESCR           AS MIN_CODE_STATUS,
                MAXCS.CREATE_INSTANT_DTTM AS MAX_CREATE_DTTM,
                MAXCS.CAT_DESCR           AS MAX_CODE_STATUS
              FROM
                (SELECT
                   CSN_ID,
                   MAX(CREATE_INSTANT_DTTM) MAX_DT,
                   MIN(CREATE_INSTANT_DTTM) MIN_DT
                 FROM DART_ODS.ODS_EDW_PT_CD_STATE
                 WHERE INACTIVE_INSTANT_DTTM <> CREATE_INSTANT_DTTM

                 GROUP BY CSN_ID
                ) MCS

                INNER JOIN

                DART_ODS.ODS_EDW_PT_CD_STATE MINCS
                  ON MCS.CSN_ID = MINCS.CSN_ID AND MCS.MIN_DT = MINCS.CREATE_INSTANT_DTTM

                INNER JOIN

                DART_ODS.ODS_EDW_PT_CD_STATE MAXCS
                  ON MCS.CSN_ID = MAXCS.CSN_ID AND MCS.MAX_DT = MAXCS.CREATE_INSTANT_DTTM

              ORDER BY
                MAXCS.CSN_ID,
                MAXCS.CREATE_INSTANT_DTTM
            ) t19 ON t1.PT_ENC_ID = t19.CSN_ID
  LEFT JOIN (
              SELECT DISTINCT
                t1.MEDICALRECORDNUMBER,
                t1.ADMISSIONDATE,
                'Y' AS ChemoFlag
              FROM DART_ODS.ODS_EPSI_CHARGES t1
              WHERE t1.HCPCS IN (
                '96401',
                '96402',
                '96405',
                '96406',
                '96409',
                '96411',
                '96413',
                '96415',
                '96416',
                '96417',
                '96425',
                '96445',
                '96446',
                '96450',
                '96521',
                '96522',
                '96523',
                '96542',
                '96549',
                'C9021',
                'C9025',
                'C9027',
                'C9131',
                'C9259',
                'C9260',
                'C9265',
                'C9273',
                'C9276',
                'C9280',
                'C9284',
                'C9287',
                'C9289',
                'C9292',
                'C9295',
                'C9296',
                'C9442',
                'C9449',
                'C9455',
                'J0202',
                'J0480',
                'J0594',
                'J0881',
                'J0882',
                'J0885',
                'J0886',
                'J0894',
                'J1050',
                'J1051',
                'J1300',
                'J1438',
                'J1440',
                'J1441',
                'J1442',
                'J1447',
                'J1561',
                'J1566',
                'J1569',
                'J1572',
                'J1745',
                'J1786',
                'J1950',
                'J2355',
                'J2425',
                'J2505',
                'J2562',
                'J2791',
                'J2796',
                'J2820',
                'J3262',
                'J3590',
                'J7502',
                'J7507',
                'J7515',
                'J7517',
                'J7520',
                'J8520',
                'J8521',
                'J8530',
                'J8600',
                'J8610',
                'J8700',
                'J8999',
                'J9000',
                'J9001',
                'J9002',
                'J9010',
                'J9015',
                'J9017',
                'J9019',
                'J9020',
                'J9025',
                'J9027',
                'J9032',
                'J9033',
                'J9035',
                'J9039',
                'J9040',
                'J9041',
                'J9042',
                'J9043',
                'J9045',
                'J9047',
                'J9050',
                'J9055',
                'J9060',
                'J9065',
                'J9070',
                'J9093',
                'J9098',
                'J9100',
                'J9120',
                'J9130',
                'J9150',
                'J9151',
                'J9155',
                'J9160',
                'J9171',
                'J9178',
                'J9179',
                'J9181',
                'J9185',
                'J9190',
                'J9201',
                'J9202',
                'J9206',
                'J9207',
                'J9208',
                'J9209',
                'J9211',
                'J9213',
                'J9214',
                'J9217',
                'J9228',
                'J9230',
                'J9245',
                'J9250',
                'J9260',
                'J9261',
                'J9263',
                'J9264',
                'J9265',
                'J9266',
                'J9267',
                'J9268',
                'J9271',
                'J9280',
                'J9293',
                'J9299',
                'J9301',
                'J9302',
                'J9303',
                'J9305',
                'J9306',
                'J9307',
                'J9308',
                'J9310',
                'J9315',
                'J9320',
                'J9328',
                'J9330',
                'J9340',
                'J9350',
                'J9351',
                'J9354',
                'J9355',
                'J9360',
                'J9370',
                'J9390',
                'J9395',
                'J9400',
                'J9999',
                'Q2043',
                'Q2048',
                'Q2049',
                'Q2050',
                'S0145',
                'S0172',
                'S0178'
              )) t20 ON t13.PT_DFCI_MRN = t20.MEDICALRECORDNUMBER AND t1.HOSP_ADMIT_DTTM = t20.ADMISSIONDATE
WHERE
  t1.PT_ID IN (
    SELECT pe.pt_id
    FROM
      dart_ods.mv_coba_pt_enc pe
    WHERE
      enc_status_descr IN (
        'ARRIVED', 'COMPLETED'
      )
      AND
      pe.enc_loc_nm_dv IN (
        'DANA-FARBER CANCER INSTITUTE LONGWOOD',
        'DANA-FARBER AT ST. ELIZABETH MEDICAL CENTER',
        'DANA-FARBER BWCC AT MILFORD REGIONAL MEDICAL CENTER',
        'DANA-FARBER BWCC SOUTH SHORE CANCER CENTER',
        'DANA-FARBER LONDONDERRY'
      )
  )
  AND
  '01-OCT-15' <= t1.cont_dttm;
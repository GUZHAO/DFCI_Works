SELECT EXTRACT(YEAR FROM ENC_APPT_DTTM) AS APPT, COUNT(*) AS CNT FROM (
  SELECT
    t1.pt_id,
    t1.ENC_ID_CSN,
    t1.ENC_APPT_DTTM,
    t1.ENC_DEPT_DESCR,
    t2.opioid_ind,
    t3.laxative_ind
  FROM
    dart_ods.mv_coba_pt_enc t1
    LEFT JOIN (
                SELECT DISTINCT
                  pt_id,
                  1 AS opioid_ind
                FROM
                  dart_ods.ods_edw_ord_med
                WHERE
                  Med_DESCR LIKE '%MS CONTIN%'
                  OR Med_DESCR LIKE '%morphine%'
                  OR Med_DESCR LIKE '%OXYCODONE%'
                  OR Med_DESCR LIKE '%FENTANYL%PATCH%'
                  OR Med_DESCR LIKE '%METHADONE%'
                  OR Med_DESCR LIKE '%DILAUDID%'
                  OR Med_DESCR LIKE '%Oxycontin%'
                GROUP BY
                  pt_id
              ) t2 ON t1.pt_id = t2.pt_id
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
                  pt_id
              ) t3 ON t1.pt_id = t3.pt_id
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
   )) WHERE
  opioid_ind = 1 AND laxative_ind = 1 AND ENC_DEPT_DESCR IN ('DF PALLIATIVE CARE', 'DF PSYCH ONC')
GROUP BY EXTRACT(YEAR FROM ENC_APPT_DTTM)
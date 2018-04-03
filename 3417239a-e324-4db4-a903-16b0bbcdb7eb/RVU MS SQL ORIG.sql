SELECT DISTINCT
  a16.EPIC_PROV_ID                        PROV_ID,
  a16.PROV_NM                             PROV_NM,
  pa11.PROV_ID0                           PROV_ID0,
  CASE WHEN a16.PROV_TYPE_DESCR IN ('PHYSICIAN')
    THEN 'MD'
  WHEN a16.PROV_TYPE_DESCR IN ('NURSE PRACTITIONER', 'PHYSICIAN ASSISTANT')
    THEN 'NP/PA'
  ELSE 'N/A' END                          PROV_TYPE_CD,
  (CASE WHEN TRIM(a12.MO_DIVISION_NM) IS NULL
    THEN 'N/A'
   ELSE TRIM(a12.MO_DIVISION_NM) END)     MO_DIVISION_NM,
  (CASE WHEN TRIM(a12.SITE_NM) IS NULL
    THEN 'N/A'
   ELSE TRIM(a12.SITE_NM) END)            SITE_NM,
  (CASE WHEN TRIM(a12.DISEASE_GRP_ABBREV) IS NULL
    THEN 'N/A'
   ELSE TRIM(a12.DISEASE_GRP_ABBREV) END) CLIN_DEPT_GRP1,
  pa11.CLIN_DEPT_ABBREV                   CLIN_DEPT_ABBREV,
  a16.DISEASE_GRP_DESCR                   DISEASE_GRP_FN_DEPT_DESCR,
  (CASE WHEN a12.DISEASE_GRP_ABBREV IN ('PALLIATIVE CARE', 'PSYCH-SOC', 'PEDI PALLIATIVE', 'ADULT PALLIATIVE CARE')
    THEN 'POPC'
   WHEN a12.DISEASE_GRP_ABBREV IN ('PEDI', 'SURGERY-PEDI')
     THEN 'PEDI'
   ELSE 'ADULT' END)                      CustCol_10,
  pa11.CustCol_14                         CustCol_14,
  (CASE WHEN a15.PROC_CD = '372288'
    THEN '99203'
   WHEN a15.PROC_CD = '372292'
     THEN '99204'
   WHEN a15.PROC_CD = '372298'
     THEN '99205'
   WHEN a15.PROC_CD = '372304'
     THEN '99211'
   WHEN a15.PROC_CD = '372322'
     THEN '99213'
   WHEN a15.PROC_CD = '372332'
     THEN '99214'
   WHEN a15.PROC_CD = '372350'
     THEN '99215'
   ELSE a15.CPT_CD END)                   CPT_CD,
  pa11.CLIN_DEPT_GRP1                     CLIN_DEPT_GRP10,
  pa11.PROV_ID                            PROV_ID1,
  a17.PROV_NM                             PROV_NM0,
  pa11.SUP_DISEASE_GRP                    SUP_DISEASE_GRP,
  pa11.CALENDAR_DT                        CALENDAR_DT,
  a13.MONTH_NBR                           MTH_NBR,
  upper(SUBSTR(a13.MTH_NM, 1, 3))         CustCol_11,
  pa11.SERVICE_CD                         SERVICE_CD,
  a15.PROC_NM                             SERVICE_DESCR,
  a16.DISEASE_SUBGRP_DESCR                DISEASE_SUBGRP_DESCR,
  pa11.MONTHLYRVU                         MONTHLYRVU,
  pa11.MONTHLYQTY                         MONTHLYQTY,
  pa14.PROVEFFORT                         PROVEFFORT,
  pa14.PROVDISTRIB                        PROVDISTRIB
FROM (SELECT
        (CASE WHEN TRIM(a17.DISEASE_GRP_ABBREV) IS NULL
          THEN 'N/A'
         ELSE TRIM(a17.DISEASE_GRP_ABBREV) END) CLIN_DEPT_GRP1,
        a16.DISEASE_GRP_DESCR                   SUP_DISEASE_GRP,
        a16.EPIC_PROV_ID                        PROV_ID,
        a15.CALENDAR_DT                         CALENDAR_DT,
        (CASE WHEN a14.PROC_CD IS NULL
          THEN 'N/A'
         ELSE a14.PROC_CD END)                  SERVICE_CD,
        (CASE WHEN a13.DISEASE_GRP_DESCR IN ('MED ONC-FH')
          THEN 'FAULKNER'
         WHEN a13.DISEASE_GRP_DESCR IN ('MED ONC-LNH')
           THEN 'LONDONDERRY'
         WHEN a13.DISEASE_GRP_DESCR IN ('MED ONC-MH')
           THEN 'MILFORD'
         WHEN a13.DISEASE_GRP_DESCR IN ('MED ONC-SS')
           THEN 'SOUTH SHORE'
         WHEN a13.DISEASE_GRP_DESCR IN ('MED ONC-SS')
           THEN 'ST ELIZABETHS'
         ELSE 'LONGWOOD' END)                   CustCol_14,
        a13.EPIC_PROV_ID                        PROV_ID0,
        (CASE WHEN a12.CLIN_DEPT_ABBREV IS NULL
          THEN 'N/A'
         ELSE a12.CLIN_DEPT_ABBREV END)         CLIN_DEPT_ABBREV,
        sum(NVL(a11.TOT_WORK_RVU_AMT, 0))       MONTHLYRVU,
        sum(a11.TOT_SERVICE_QTY)                MONTHLYQTY
      FROM (SELECT
              RVU.PROV_DIM_SEQ,
              RVU.PROC_DIM_SEQ,
              BEG_MTH_DIM_SEQ,
              INST_DIM_SEQ,
              CLIN_DEPT_DIM_SEQ,
              INPAT_OUTPAT_IND,
              (CASE WHEN PROV.PROV_TYPE_DESCR = 'PHYSICIAN'
                THEN -1
               ELSE SUPER_PROV_DIM_SEQ END) SUPER_PROV_DIM_SEQ,
              TOT_SERVICE_QTY,
              TOT_WORK_RVU_AMT,
              TOT_SERVICE_AMT,
              RVU.DART_CREATE_DTTM
            FROM DARTEDM.F_MTHLY_PROV_SERVICE_RVU RVU
              JOIN DARTEDM.D_PROV PROV
                ON RVU.PROV_DIM_SEQ = PROV.PROV_DIM_SEQ) a11
        LEFT OUTER JOIN DARTEDM.D_CLIN_DEPT a12
          ON (a11.CLIN_DEPT_DIM_SEQ = a12.CLIN_DEPT_DIM_SEQ)
        LEFT OUTER JOIN DARTEDM.D_PROV a13
          ON (a11.PROV_DIM_SEQ = a13.PROV_DIM_SEQ)
        LEFT OUTER JOIN DARTEDM.D_PROC a14
          ON (a11.PROC_DIM_SEQ = a14.PROC_DIM_SEQ)
        LEFT OUTER JOIN DARTEDM.D_CALENDAR a15
          ON (a11.BEG_MTH_DIM_SEQ = a15.CALENDAR_DIM_SEQ)
        LEFT OUTER JOIN DARTEDM.D_PROV a16
          ON ((CASE WHEN a11.SUPER_PROV_DIM_SEQ = -1
          THEN a11.PROV_DIM_SEQ
               ELSE a11.SUPER_PROV_DIM_SEQ END) = a16.PROV_DIM_SEQ)
        LEFT OUTER JOIN DARTEDM.MV_RVU_REPORT_CATEGORY a17
          ON ((CASE WHEN a12.CLIN_DEPT_ABBREV IS NULL
          THEN 'N/A'
               ELSE a12.CLIN_DEPT_ABBREV END) = (CASE WHEN a17.CLIN_DEPT_ABBREV IS NULL
          THEN 'N/A'
                                                 ELSE a17.CLIN_DEPT_ABBREV END) AND
              a16.EPIC_PROV_ID = a17.EPIC_PROV_ID)
      WHERE a15.CALENDAR_DT BETWEEN To_Date('01-07-2017', 'dd-mm-yyyy') AND To_Date('30-09-2017', 'dd-mm-yyyy')
      GROUP BY (CASE WHEN TRIM(a17.DISEASE_GRP_ABBREV) IS NULL
        THEN 'N/A'
                ELSE TRIM(a17.DISEASE_GRP_ABBREV) END),
        a16.DISEASE_GRP_DESCR,
        a16.EPIC_PROV_ID,
        a15.CALENDAR_DT,
        (CASE WHEN a14.PROC_CD IS NULL
          THEN 'N/A'
         ELSE a14.PROC_CD END),
        (CASE WHEN a13.DISEASE_GRP_DESCR IN ('MED ONC-FH')
          THEN 'FAULKNER'
         WHEN a13.DISEASE_GRP_DESCR IN ('MED ONC-LNH')
           THEN 'LONDONDERRY'
         WHEN a13.DISEASE_GRP_DESCR IN ('MED ONC-MH')
           THEN 'MILFORD'
         WHEN a13.DISEASE_GRP_DESCR IN ('MED ONC-SS')
           THEN 'SOUTH SHORE'
         WHEN a13.DISEASE_GRP_DESCR IN ('MED ONC-SS')
           THEN 'ST ELIZABETHS'
         ELSE 'LONGWOOD' END),
        a13.EPIC_PROV_ID,
        (CASE WHEN a12.CLIN_DEPT_ABBREV IS NULL
          THEN 'N/A'
         ELSE a12.CLIN_DEPT_ABBREV END)
     ) pa11
  LEFT OUTER JOIN DARTEDM.MV_RVU_REPORT_CATEGORY a12
    ON (pa11.CLIN_DEPT_ABBREV = (CASE WHEN a12.CLIN_DEPT_ABBREV IS NULL
    THEN 'N/A'
                                 ELSE a12.CLIN_DEPT_ABBREV END) AND
        pa11.PROV_ID0 = a12.EPIC_PROV_ID)
  LEFT OUTER JOIN DARTEDM.D_CALENDAR a13
    ON (pa11.CALENDAR_DT = a13.CALENDAR_DT)
  LEFT OUTER JOIN (SELECT
                     a11.ACADEMIC_YR              ACADEMIC_YR,
                     (CASE WHEN a11.PROV_ALLOC_DISEASE_GRP = 'MED ONC-LNH'
                       THEN 'LONDONDERRY'
                      WHEN a11.PROV_ALLOC_DISEASE_GRP = 'MED ONC-MH'
                        THEN 'MILFORD'
                      WHEN a11.PROV_ALLOC_DISEASE_GRP = 'MED ONC-SS'
                        THEN 'SOUTH SHORE'
                      WHEN a11.PROV_ALLOC_DISEASE_GRP = 'MED ONC-SE'
                        THEN 'ST ELIZABETHS'
                      ELSE 'LONGWOOD' END)        SITE_NM,
                     a11.PROV_ALLOC_DISEASE_GRP   CLIN_DEPT_GRP1,
                     a12.EPIC_PROV_ID             PROV_ID,
                     sum((a11.EFFORT_PCT / 100))  PROVEFFORT,
                     sum((a11.DISTRIB_PCT / 100)) PROVDISTRIB
                   FROM (SELECT
                           PROV_DIM_SEQ,
                           EMPL_NM,
                           PROV_NM,
                           EMPL_ID,
                           EPIC_PROV_ID,
                           PROV_STATUS,
                           PROV_TYPE_DESCR,
                           ACADEMIC_YR,
                           PROV_PRIM_DISEASE_GRP,
                           XREF.DISEASE_GRP_DESCR PROV_ALLOC_DISEASE_GRP,
                           EFF.FN_DEPT_ID,
                           FN_DEPT_NM,
                           WEEKLY_HOURS,
                           DAILY_EFFORT_PCT_SUM,
                           DAILY_DISTRIB_PCT_SUM,
                           DAYS_IN_YEAR,
                           EFFORT_PCT,
                           DISTRIB_PCT
                         FROM DARTEDM.MV_RVU_PROV_EFFORT EFF
                           JOIN MICROSTRAT.DS_FN_DEPT_DISEASE_GRP_XREF XREF
                             ON EFF.FN_DEPT_ID = XREF.FN_DEPT_ID) a11
                     LEFT OUTER JOIN DARTEDM.D_PROV a12
                       ON (a11.PROV_DIM_SEQ = a12.PROV_DIM_SEQ)
                   WHERE a11.ACADEMIC_YR = (SELECT ACADEMIC_YR
                                            FROM DARTEDM.D_CALENDAR
                                            WHERE CALENDAR_DT = To_Date('30-09-2017', 'dd-mm-yyyy'))
                   GROUP BY a11.ACADEMIC_YR,
                     (CASE WHEN a11.PROV_ALLOC_DISEASE_GRP = 'MED ONC-LNH'
                       THEN 'LONDONDERRY'
                      WHEN a11.PROV_ALLOC_DISEASE_GRP = 'MED ONC-MH'
                        THEN 'MILFORD'
                      WHEN a11.PROV_ALLOC_DISEASE_GRP = 'MED ONC-SS'
                        THEN 'SOUTH SHORE'
                      WHEN a11.PROV_ALLOC_DISEASE_GRP = 'MED ONC-SE'
                        THEN 'ST ELIZABETHS'
                      ELSE 'LONGWOOD' END),
                     a11.PROV_ALLOC_DISEASE_GRP,
                     a12.EPIC_PROV_ID
                  ) pa14
    ON ((CASE WHEN TRIM(a12.DISEASE_GRP_ABBREV) IS NULL
    THEN 'N/A'
         ELSE TRIM(a12.DISEASE_GRP_ABBREV) END) = pa14.CLIN_DEPT_GRP1 AND
        (CASE WHEN TRIM(a12.SITE_NM) IS NULL
          THEN 'N/A'
         ELSE TRIM(a12.SITE_NM) END) = pa14.SITE_NM AND
        a13.ACADEMIC_YR = pa14.ACADEMIC_YR AND
        pa11.PROV_ID0 = pa14.PROV_ID)
  LEFT OUTER JOIN DARTEDM.D_PROC a15
    ON (pa11.SERVICE_CD = (CASE WHEN a15.PROC_CD IS NULL
    THEN 'N/A'
                           ELSE a15.PROC_CD END))
  LEFT OUTER JOIN DARTEDM.D_PROV a16
    ON (pa11.PROV_ID0 = a16.EPIC_PROV_ID)
  LEFT OUTER JOIN DARTEDM.D_PROV a17
    ON (pa11.PROV_ID = a17.EPIC_PROV_ID)
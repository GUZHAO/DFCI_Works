SELECT
  t1.*
FROM (
       SELECT
         t1.*,
         CASE WHEN t1.ROW_RANK = 1
           THEN t1.ORD_DTTM
         ELSE t1.PREV_ORD_DTTM END                              AS NEW_PREV_ORD_DTTM,
         MONTHS_BETWEEN(t1.ORD_DTTM, CASE WHEN t1.ROW_RANK = 1
           THEN t1.ORD_DTTM
                                     ELSE t1.PREV_ORD_DTTM END) AS GAP
       FROM (
              SELECT
                t1.*,
                RANK()
                OVER (
                  PARTITION BY t1.DFCI_MRN
                  ORDER BY t1.ORD_DTTM, t1.ORD_ID ) AS ROW_RANK,
                LAG(t1.ORD_DTTM, 1, NULL)
                OVER (
                  ORDER BY t1.DFCI_MRN )            AS PREV_ORD_DTTM
              FROM (
                     SELECT t1.*
                     FROM (
                            SELECT DISTINCT
                              OM.ORD_ID,
                              PE.PT_DFCI_MRN             AS DFCI_MRN,
                              OM.ORD_DTTM,
                              PE.ENC_DEPT_DESCR,
                              OM.MED_ID,
                              OM.MED_DESCR,
                              OM.MED_DISPL_NM,
                              OM.MED_ROUTE_DESCR,
                              P.PROV_NM,
                              PE.ENC_LOC_NM_DV,
                              PE.ENC_DT,
                              RM.THER_CLS_DESCR,
                              CASE WHEN OM.MED_DISPL_NM LIKE '%AFINITOR%' OR
                                        OM.MED_DISPL_NM LIKE '%ALECENSA%' OR
                                        OM.MED_DISPL_NM LIKE '%ALKERAN%' OR
                                        OM.MED_DISPL_NM LIKE '%ALUNBRIG%' OR
                                        OM.MED_DISPL_NM LIKE '%BELEODAQ%' OR
                                        OM.MED_DISPL_NM LIKE '%BOSULIF%' OR
                                        OM.MED_DISPL_NM LIKE '%CABOMETYX%' OR
                                        OM.MED_DISPL_NM LIKE '%CAPRELSA%' OR
                                        OM.MED_DISPL_NM LIKE '%CEENU%' OR
                                        OM.MED_DISPL_NM LIKE '%COTELLIC%' OR
                                        OM.MED_DISPL_NM LIKE '%CYTOXAN%' OR
                                        OM.MED_DISPL_NM LIKE '%ERIVEDGE%' OR
                                        OM.MED_DISPL_NM LIKE '%FARYDAK%' OR
                                        OM.MED_DISPL_NM LIKE '%GILOTRIF%' OR
                                        OM.MED_DISPL_NM LIKE '%GLEEVEC%' OR
                                        OM.MED_DISPL_NM LIKE '%HYDREA%' OR
                                        OM.MED_DISPL_NM LIKE '%IBRANCE%' OR
                                        OM.MED_DISPL_NM LIKE '%ICLUSIG%' OR
                                        OM.MED_DISPL_NM LIKE '%IDHIFA%' OR
                                        OM.MED_DISPL_NM LIKE '%IMBRUVICA%' OR
                                        OM.MED_DISPL_NM LIKE '%INLYTA%' OR
                                        OM.MED_DISPL_NM LIKE '%IRESSA%' OR
                                        OM.MED_DISPL_NM LIKE '%JAKAFI%' OR
                                        OM.MED_DISPL_NM LIKE '%KISQALI%' OR
                                        OM.MED_DISPL_NM LIKE '%LENVIMA%' OR
                                        OM.MED_DISPL_NM LIKE '%LEUKERAN%' OR
                                        OM.MED_DISPL_NM LIKE '%LONSURF%' OR
                                        OM.MED_DISPL_NM LIKE '%LYNPARZA%' OR
                                        OM.MED_DISPL_NM LIKE '%MEKANIST%' OR
                                        OM.MED_DISPL_NM LIKE '%MYLERAN%' OR
                                        OM.MED_DISPL_NM LIKE '%NERLYNX%' OR
                                        OM.MED_DISPL_NM LIKE '%NEXAVAR%' OR
                                        OM.MED_DISPL_NM LIKE '%NINLARO%' OR
                                        OM.MED_DISPL_NM LIKE '%ODOMZO%' OR
                                        OM.MED_DISPL_NM LIKE '%POMALYST%' OR
                                        OM.MED_DISPL_NM LIKE '%PURIXAN%' OR
                                        OM.MED_DISPL_NM LIKE '%REVLIMID%' OR
                                        OM.MED_DISPL_NM LIKE '%RHEUMATREX%' OR
                                        OM.MED_DISPL_NM LIKE '%RUBRACA%' OR
                                        OM.MED_DISPL_NM LIKE '%RYDAPT%' OR
                                        OM.MED_DISPL_NM LIKE '%SPRYCEL%' OR
                                        OM.MED_DISPL_NM LIKE '%STIVARGA%' OR
                                        OM.MED_DISPL_NM LIKE '%SUTENT%' OR
                                        OM.MED_DISPL_NM LIKE '%TAFLINAR%' OR
                                        OM.MED_DISPL_NM LIKE '%TAGRISSO%' OR
                                        OM.MED_DISPL_NM LIKE '%TARCEVA%' OR
                                        OM.MED_DISPL_NM LIKE '%TARGRETIN%' OR
                                        OM.MED_DISPL_NM LIKE '%TASIGNA%' OR
                                        OM.MED_DISPL_NM LIKE '%TEMODAR%' OR
                                        OM.MED_DISPL_NM LIKE '%THALOMID%' OR
                                        OM.MED_DISPL_NM LIKE '%TOPOSAR%' OR
                                        OM.MED_DISPL_NM LIKE '%TREXALL%' OR
                                        OM.MED_DISPL_NM LIKE '%TYKERB%' OR
                                        OM.MED_DISPL_NM LIKE '%VENCLEXTA%' OR
                                        OM.MED_DISPL_NM LIKE '%VEPESID%' OR
                                        OM.MED_DISPL_NM LIKE '%VERZENIO%' OR
                                        OM.MED_DISPL_NM LIKE '%VOTRIENT%' OR
                                        OM.MED_DISPL_NM LIKE '%XALKORI%' OR
                                        OM.MED_DISPL_NM LIKE '%XELODA%' OR
                                        OM.MED_DISPL_NM LIKE '%ZEJULA%' OR
                                        OM.MED_DISPL_NM LIKE '%ZELBORAF%' OR
                                        OM.MED_DISPL_NM LIKE '%ZOLINZA%' OR
                                        OM.MED_DISPL_NM LIKE '%ZYDELIG%' OR
                                        OM.MED_DISPL_NM LIKE '%ZYKADIA%' OR
                                        OM.MED_DISPL_NM LIKE '%ABEMACICLIB%' OR
                                        OM.MED_DISPL_NM LIKE '%AFATINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%ALECTINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%AXITINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%BELINOSTAT%' OR
                                        OM.MED_DISPL_NM LIKE '%BEXAROTENE%' OR
                                        OM.MED_DISPL_NM LIKE '%BOSUTINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%BRIGATINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%BUSULFAN%' OR
                                        OM.MED_DISPL_NM LIKE '%CABOZANTINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%CAPECITABINE%' OR
                                        OM.MED_DISPL_NM LIKE '%CERITINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%CHLORAMBUCIL%' OR
                                        OM.MED_DISPL_NM LIKE '%COBIMETINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%CRIZOTINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%CYCLOPHOSPHAMIDE%' OR
                                        OM.MED_DISPL_NM LIKE '%DABRAFENIB%' OR
                                        OM.MED_DISPL_NM LIKE '%DASATINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%ENASIDENIB%' OR
                                        OM.MED_DISPL_NM LIKE '%ERLOTINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%ETOPOSIDE%' OR
                                        OM.MED_DISPL_NM LIKE '%EVEROLIMUS%' OR
                                        OM.MED_DISPL_NM LIKE '%GEFITINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%HYDROXYUREA%' OR
                                        OM.MED_DISPL_NM LIKE '%IBRUTINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%IDELALISIB%' OR
                                        OM.MED_DISPL_NM LIKE '%IMATINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%ISOTRETINOIN%' OR
                                        OM.MED_DISPL_NM LIKE '%IXAZOMIB%' OR
                                        OM.MED_DISPL_NM LIKE '%LAPATINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%LENALIDOMIDE%' OR
                                        OM.MED_DISPL_NM LIKE '%LENVATINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%LOMUSTINE%' OR
                                        OM.MED_DISPL_NM LIKE '%MELPHALAN%' OR
                                        OM.MED_DISPL_NM LIKE '%MERCAPTOPURINE%' OR
                                        OM.MED_DISPL_NM LIKE '%METHOTREXATE%' OR
                                        OM.MED_DISPL_NM LIKE '%MIDOSTAURIN%' OR
                                        OM.MED_DISPL_NM LIKE '%NERATINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%NILOTINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%NIRAPARIB%' OR
                                        OM.MED_DISPL_NM LIKE '%OLAPARIB%' OR
                                        OM.MED_DISPL_NM LIKE '%OSIMERTINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%PALBOCICLIB%' OR
                                        OM.MED_DISPL_NM LIKE '%PANOBINOSTAT%' OR
                                        OM.MED_DISPL_NM LIKE '%PAZOPANIB%' OR
                                        OM.MED_DISPL_NM LIKE '%POMALIDOMIDE%' OR
                                        OM.MED_DISPL_NM LIKE '%PONATINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%PROCARBAZINE%' OR
                                        OM.MED_DISPL_NM LIKE '%REGORAFENIB%' OR
                                        OM.MED_DISPL_NM LIKE '%RIBOCICLIB%' OR
                                        OM.MED_DISPL_NM LIKE '%RUCAPARIB%' OR
                                        OM.MED_DISPL_NM LIKE '%RUXOLITINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%SONIDEGIB%' OR
                                        OM.MED_DISPL_NM LIKE '%SORAFENIB%' OR
                                        OM.MED_DISPL_NM LIKE '%SUNITINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%TEMOZOLOMIDE%' OR
                                        OM.MED_DISPL_NM LIKE '%THALIDOMIDE%' OR
                                        OM.MED_DISPL_NM LIKE '%TRAMETINIB%' OR
                                        OM.MED_DISPL_NM LIKE '%TRETINOIN%' OR
                                        OM.MED_DISPL_NM LIKE '%TRIFLURIDINE%' OR
                                        OM.MED_DISPL_NM LIKE '%TIPIRACIL%' OR
                                        OM.MED_DISPL_NM LIKE '%VANDETANIB%' OR
                                        OM.MED_DISPL_NM LIKE '%VEMURAFENIB%' OR
                                        OM.MED_DISPL_NM LIKE '%VENETOCLAX%' OR
                                        OM.MED_DISPL_NM LIKE '%VISMODEGIB%' OR
                                        OM.MED_DISPL_NM LIKE '%VORINOSTAT%'
                                THEN 'Y'
                              ELSE 'N' END               AS ORAL_CHEMO_DRUG_FLAG,
                              OM.PT_ID,
                              PE.PT_LAST_NM,
                              PE.PT_FIRST_NM,
                              TP.PLAN_ID,
                              TP.PLAN_NM,
                              TP.PLAN_RECORD_TYP_DESCR,
                              TP.CREATED_DTTM,
                              TP.PLAN_START_DTTM,
                              TP.PROV_ID                 AS TX_PLAN_PROV_ID,
                              TXPP.PROV_NM               AS TX_PLAN_PROV_NM,
                              P.PROV_DX_GRP_DV           AS DISEASE_GROUP,
                              TP.TX_DEPT_ID              AS TX_PLAN_DEPT_ID,
                              TXD.DEPT_NM                AS TX_PLAN_DEPT_NM,
                              TPI.ORD_TMPLT_ID
                            FROM DART_ODS.ODS_EDW_ORD_MED OM
                              LEFT JOIN DART_ODS.ODS_EDW_ORD_TMPLT_TRACK OTT
                                ON OM.ORD_ID = OTT.ORD_ID
                              LEFT JOIN DART_ODS.ODS_EDW_ORD_TX_PLAN_INFO TPI
                                ON OTT.ORD_ID = TPI.ORD_ID
                              LEFT JOIN DART_ODS.ODS_EDW_CLIN_TX_PLAN TP
                                ON TPI.TMPLT_PLAN_ID = TP.PLAN_ID
                              LEFT JOIN DART_ODS.MV_COBA_PROV TXPP
                                ON TXPP.PROV_ID = TP.PROV_ID
                              LEFT JOIN DART_ODS.MV_COBA_PROV P
                                ON OM.ORD_PROV_ID = P.PROV_ID
                              LEFT JOIN DART_ODS.MV_COBA_DEPT TXD
                                ON TP.TX_DEPT_ID = TXD.DEPT_ID
                              LEFT JOIN DART_ODS.ODS_EDW_REF_MED RM
                                ON OM.MED_ID = RM.MED_ID
                              LEFT JOIN DART_ODS.MV_COBA_PT_ENC PE
                                ON OM.PT_ENC_ID = PE.ENC_ID_CSN
                            WHERE
                              (RM.THER_CLS_DESCR = 'ANTINEOPLASTICS'
                               OR RM.THER_CLS_DESCR IS NULL) AND
                              (OM.ORD_STATE_DESCR <> 'CANCELED'
                               OR OM.ORD_STATE_DESCR IS NULL) AND
                              PE.ENC_DEPT_DESCR LIKE 'DF%'
                          ) t1
                     WHERE t1.MED_ROUTE_DESCR = 'ORAL' AND t1.ORAL_CHEMO_DRUG_FLAG = 'Y'
                   ) t1
            ) t1
     ) t1
WHERE t1.ROW_RANK = 1 OR t1.GAP >= 6;

----------------------------------------------------------
SELECT
  CASE WHEN OTT.ORD_TMPLT_TX_PLAN_ID IS NULL
    THEN 'NULL Value'
  ELSE 'NON NULL value' END AS TMPLT_TX_PLAN_ID,
  COUNT(*)                  AS CNT
FROM DART_ODS.ODS_EDW_ORD_TMPLT_TRACK OTT
GROUP BY CASE WHEN OTT.ORD_TMPLT_TX_PLAN_ID IS NULL
  THEN 'NULL Value'
         ELSE 'NON NULL value' END;

SELECT
  CASE WHEN TPI.ORD_TMPLT_ID IS NULL
    THEN 'NULL Value'
  ELSE 'NON NULL value' END AS ORD_TMPLT_ID,
  COUNT(*)                  AS CNT
FROM DART_ODS.ODS_EDW_ORD_TX_PLAN_INFO TPI
GROUP BY CASE WHEN TPI.ORD_TMPLT_ID IS NULL
  THEN 'NULL Value'
         ELSE 'NON NULL value' END;

-----------------------------
SELECT
  CASE WHEN OTT.ORD_ID IS NULL
    THEN 'Not Matching'
  ELSE 'Machting' END AS Result,
  COUNT(*)            AS CNT
FROM (SELECT *
      FROM DART_ODS.ODS_EDW_ORD_TX_PLAN_INFO t1
     ) TPI
  LEFT JOIN DART_ODS.ODS_EDW_ORD_TMPLT_TRACK OTT ON TPI.ORD_ID = OTT.ORD_ID
GROUP BY CASE WHEN OTT.ORD_ID IS NULL
  THEN 'Not Matching'
         ELSE 'Machting' END;

--------------------------------
SELECT
  CASE WHEN TPI.TMPLT_PLAN_ID IS NULL
    THEN 'Not Matching'
  ELSE 'Matching' END AS Result,
  COUNT(*)            AS CNT
FROM (SELECT *
      FROM DART_ODS.ODS_EDW_CLIN_TX_PLAN t1
     ) TP
  LEFT JOIN DART_ODS.ODS_EDW_ORD_TX_PLAN_INFO TPI ON TP.PLAN_ID = TPI.TMPLT_PLAN_ID
GROUP BY CASE WHEN TPI.TMPLT_PLAN_ID IS NULL
  THEN 'Not Matching'
         ELSE 'Matching' END

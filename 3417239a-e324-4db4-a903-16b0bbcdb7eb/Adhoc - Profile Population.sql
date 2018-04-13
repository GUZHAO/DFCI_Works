-- t2.ENC_LOC_NM_DV IN
--              ('DANA-FARBER CANCER INSTITUTE LONGWOOD', 'DANA-FARBER AT ST. ELIZABETH MEDICAL CENTER', 'DANA-FARBER BWCC AT MILFORD REGIONAL MEDICAL CENTER', 'DANA-FARBER BWCC SOUTH SHORE CANCER CENTER', 'DANA-FARBER LONDONDERRY')
--              AND
SELECT
  t1.DFCI_MRN,
  t1.SITE,
  t1.PT_DEATH_DT
FROM (
       SELECT
         t1.DFCI_MRN,
         t1.SITE,
         t1.PT_DEATH_DT,
         ROW_NUMBER()
         OVER (
           PARTITION BY t1.DFCI_MRN
           ORDER BY t1.SITE ) AS ROW_NUM
       FROM (
              SELECT DISTINCT
                t2.PT_DFCI_MRN       AS DFCI_MRN,
                CASE WHEN t2.ENC_LOC_NM_DV = 'DANA-FARBER CANCER INSTITUTE LONGWOOD'
                  THEN 'MAIN CAMPUS'
                ELSE 'SATELLITE' END AS SITE,
                t3.PT_DEATH_DT

              FROM dart_ods.ods_edw_enc_pt_enc t1
                LEFT JOIN DART_ODS.MV_COBA_PT_ENC t2 ON t1.PT_ID = t2.PT_ID
                LEFT JOIN DART_ODS.MV_COBA_PT t3 ON t1.PT_ID = t3.PT_ID
              WHERE t1.CONT_DTTM >= '30-MAY-15'
            ) t1
     ) t1
WHERE t1.ROW_NUM = 1;


SELECT
  t1.DFCI_MRN,
  t1.EXAM_FLAG,
  t1.CONSULT_FLAG
FROM (
       SELECT
         t1.DFCI_MRN,
         t1.EXAM_FLAG,
         t1.EXAM_FLAG                   AS CONSULT_FLAG,
         ROW_NUMBER()
         OVER (
           PARTITION BY t1.DFCI_MRN
           ORDER BY t1.EXAM_FLAG DESC ) AS ROW_NUM
       FROM (
              SELECT DISTINCT
                t4.MEDICALRECORDNUMBER AS DFCI_MRN,
                CASE WHEN t4.HCPCS IN
                          ('92506', '92507', '92526', '92597', '92610', '96040', '97802', '97803', '99024', '99071', '99201', '99202', '99203', '99204', '99205', '99211', '99212', '99213', '99214', '99215', '99241', '99242', '99243', '99244', '99245', '99284', '99285', '99291', '99354', '99355', '99363', '99364', '99396', '99397', 'G0101', 'G0463')
                          AND t4.DETAILTOTALCHARGES <> 0
                  THEN 'Y'
                WHEN t4.ACTIVITYCODE = '9604' AND t4.DETAILTOTALCHARGES <> 0
                  THEN 'Y'
                ELSE 'N' END           as EXAM_FLAG
              FROM DART_ODS.ODS_EPSI_CHARGES t4
            ) t1
     ) t1
WHERE t1.ROW_NUM = 1;


SELECT
  t1.DFCI_MRN,
  t1.INFUSION_FLAG
FROM (
       SELECT
         t1.DFCI_MRN,
         t1.INFUSION_FLAG,
         ROW_NUMBER()
         OVER (
           PARTITION BY t1.DFCI_MRN
           ORDER BY t1.INFUSION_FLAG DESC ) AS ROW_NUM
       FROM (
              SELECT DISTINCT
                t4.MEDICALRECORDNUMBER AS DFCI_MRN,
                CASE WHEN t4.HCPCS IN
                          ('36430', '36514', '96360', '96361', '96365', '96366', '96367', '96368', '96369', '96372', '96374', '96375', '96376', '96401', '96402', '96405', '96406', '96409', '96411', '96413', '96415', '96416', '96417', '96425', '96445', '96446', '96450', '96521', '96522', '96523', '96542', '96549', 'C8957', 'C9021', 'C9025', 'C9027', 'C9113',
                                                                                                                                                                                                                                                                                                                  'C9131', 'C9132', 'C9136', 'C9254', 'C9259', 'C9260', 'C9265', 'C9272', 'C9273', 'C9276', 'C9280', 'C9284', 'C9285', 'C9287', 'C9289', 'C9292', 'C9295', 'C9296', 'C9399', 'C9441', 'C9442', 'C9449', 'C9455', 'J0131', 'J0132', 'J0133', 'J0153', 'J0171', 'J0202', 'J0280', 'J0282', 'J0289', 'J0290', 'J0295', 'J0330', 'J0360', 'J0456',
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    'J0461', 'J0480', 'J0515', 'J0561', 'J0583', 'J0585', 'J0594', 'J0610', 'J0630', 'J0636', 'J0640', 'J0690', 'J0692', 'J0696', 'J0698', 'J0713', 'J0735', 'J0740', 'J0743', 'J0744', 'J0780', 'J0834', 'J0835', 'J0878', 'J0881', 'J0882', 'J0885', 'J0886', 'J0894', 'J0895', 'J0897', 'J1020', 'J1030', 'J1050', 'J1051', 'J1071', 'J1080',
                            'J1100', 'J1120', 'J1160', 'J1165', 'J1170', 'J1190', 'J1200', 'J1205', 'J1230', 'J1250', 'J1265', 'J1290', 'J1300', 'J1325', 'J1335', 'J1364', 'J1438', 'J1439', 'J1440', 'J1441', 'J1442', 'J1446', 'J1447', 'J1450', 'J1453', 'J1455', 'J1561', 'J1566', 'J1569', 'J1570', 'J1572', 'J1580', 'J1610', 'J1626', 'J1630', 'J1642', 'J1644', 'J1645', 'J1650', 'J1652',
                            'J1720', 'J1740', 'J1745', 'J1750', 'J1756', 'J1785', 'J1786', 'J1815', 'J1817', 'J1833', 'J1885', 'J1930', 'J1931', 'J1940', 'J1950', 'J1953', 'J1956', 'J2001', 'J2020', 'J2060', 'J2150', 'J2175', 'J2185', 'J2210', 'J2212', 'J2248', 'J2250', 'J2270', 'J2280', 'J2300', 'J2310', 'J2353', 'J2354', 'J2355', 'J2370', 'J2400', 'J2405', 'J2425', 'J2430', 'J2469',
                            'J2504', 'J2505', 'J2540', 'J2543', 'J2545', 'J2550', 'J2562', 'J2597', 'J2700', 'J2704', 'J2710', 'J2720', 'J2765', 'J2780', 'J2783', 'J2785', 'J2790', 'J2791', 'J2792', 'J2795', 'J2796', 'J2805', 'J2820', 'J2860', 'J2916', 'J2920', 'J2930', 'J2997', 'J3010', 'J3230', 'J3262', 'J3301', 'J3360', 'J3370', 'J3410', 'J3411', 'J3420', 'J3430', 'J3465', 'J3470',
                            'J3475', 'J3480', 'J3487', 'J3488', 'J3489', 'J3490', 'J3590', 'J7030', 'J7040', 'J7042', 'J7050', 'J7060', 'J7070', 'J7120', 'J7178', 'J7185', 'J7187', 'J7189', 'J7192', 'J7194', 'J7195', 'J7196', 'J7197', 'J7198', 'J7199', 'J7205', 'J7502', 'J7504', 'J7506', 'J7507', 'J7509', 'J7510', 'J7511', 'J7512', 'J7515', 'J7517', 'J7518', 'J7520', 'J7525', 'J7608',
                            'J7611', 'J7613', 'J7620', 'J7626', 'J7644', 'J8501', 'J8520', 'J8521', 'J8530', 'J8540', 'J8600', 'J8610', 'J8700', 'J8999', 'J9000', 'J9001', 'J9002', 'J9010', 'J9015', 'J9017', 'J9019', 'J9020', 'J9025', 'J9027', 'J9032', 'J9033', 'J9035', 'J9039', 'J9040', 'J9041', 'J9042', 'J9043', 'J9045', 'J9047', 'J9050', 'J9055', 'J9060', 'J9065', 'J9070', 'J9093',
                            'J9098', 'J9100', 'J9120', 'J9130', 'J9150', 'J9151', 'J9155', 'J9160', 'J9171', 'J9178', 'J9179', 'J9181', 'J9185', 'J9190', 'J9201', 'J9202', 'J9206', 'J9207', 'J9208', 'J9209', 'J9211', 'J9213', 'J9214', 'J9217', 'J9228', 'J9230', 'J9245', 'J9250', 'J9260', 'J9261', 'J9263', 'J9264', 'J9265', 'J9266', 'J9267', 'J9268', 'J9271', 'J9280', 'J9293', 'J9299',
                            'J9301', 'J9302', 'J9303', 'J9305', 'J9306', 'J9307', 'J9308', 'J9310', 'J9315', 'J9320', 'J9328', 'J9330', 'J9340', 'J9350', 'J9351', 'J9354', 'J9355', 'J9360', 'J9370', 'J9390', 'J9395', 'J9400', 'J9999', 'P9011', 'P9012', 'P9016', 'P9017', 'P9019', 'P9022', 'P9033', 'P9035', 'P9037', 'P9038', 'P9040', 'P9045', 'P9046', 'P9047', 'P9052', 'P9054', 'P9057',
                            'P9059', 'Q0138', 'Q0139', 'Q0161', 'Q0162', 'Q0163', 'Q0164', 'Q0165', 'Q0166', 'Q0167', 'Q0168', 'Q0169', 'Q0170', 'Q0172', 'Q0173', 'Q0175', 'Q0177', 'Q0179', 'Q2043', 'Q2048', 'Q2049', 'Q2050', 'Q2051', 'Q4116', 'Q9970', 'Q9975', 'S0020', 'S0028', 'S0030', 'S0039', 'S0073', 'S0077', 'S0080', 'S0119', 'S0145', 'S0160', 'S0164', 'S0171', 'S0172', 'S0178', 'S0183', 'S5010')
                          AND t4.USERFIELD1 IN
                              ('BLC', 'CRC', 'CRP', 'D10', 'D11', 'D1B', 'DF CENTRAL PHARM LNH', 'DF CENTRAL PHARM MIL', 'DF CENTRAL PHARM SS', 'DF CENTRAL PHARMACY', 'DF INF IN RAD ONC SS', 'DF INFUSION LNH', 'DF INFUSION MIL', 'DF INFUSION ROOM SS', 'DF INFUSION SE', 'DF INFUSION YAWKEY 10', 'DF INFUSION YAWKEY 11', 'DF INFUSION YAWKEY 6', 'DF INFUSION YAWKEY 7',
                                                                                                                                                                                               'DF INFUSION YAWKEY 8', 'DF INFUSION YAWKEY 9', 'DF LP INF IN RAD ONC', 'DF PEDI INFUSION', 'DF PEDI PHLEBOTOMY', 'DF PHARMACY SE', 'FFS', 'FIN', 'FSU', 'LFS', 'LIN', 'LNH PHARMACY', 'LNHRX', 'LPI', 'MILFORD PHARMACY', 'MIN', 'MRX', 'N11', 'PHA', 'PIR', 'SE PHARMACY', 'SEI', 'SIN', 'SIR', 'SS PHARMACY', 'SSRX', 'SWI', 'Y10', 'Y11', 'Y6I', 'Y7I', 'Y8I', 'Y9I')
                  THEN 'Y'
                ELSE 'N' END           AS INFUSION_FLAG
              FROM DART_ODS.ODS_EPSI_CHARGES t4
            ) t1
     ) t1
WHERE t1.ROW_NUM = 1

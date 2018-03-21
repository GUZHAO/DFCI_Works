import cx_Oracle
import struct

print(struct.calcsize("P") * 8)

connection = cx_Oracle.connect("COBATABLEAU", "Bobby1234", "dfcinp01-scan:1521/dartprdo")
cursor = connection.cursor()
cursor.execute("""
    SELECT PROV_ID
    FROM dart_ods.mv_coba_prov
    WHERE PROV_ZIP_CD = :zcd""",
    zcd='02478',)
for PROV_ID in cursor:
    print("Values:", PROV_ID)
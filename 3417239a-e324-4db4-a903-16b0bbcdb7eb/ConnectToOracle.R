Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jre1.8.0_161') # for 64-bit version
library(rJava)
library(RJDBC)

jdbcDriver <- JDBC(driverClass = "oracle.jdbc.OracleDriver", classPath = "C:/Users/gz056/Downloads/ojdbc6.jar")
jdbcConnection <- dbConnect(jdbcDriver, "jdbc:oracle:thin:@//dfcinp01-scan:1521/dartprdo", "COBATABLEAU", "Bobby1234")
PROV <- dbGetTables(jdbcConnection, schema = "DART_ODS")
PROV


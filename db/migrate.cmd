@Echo Off
migration_script.rb %HOME%\test-db\testDB.script | %JDK_HOME%\bin\native2ascii.exe  -encoding UTF-8 -reverse > import.sql

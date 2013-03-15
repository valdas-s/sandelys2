@Echo Off
setlocal

set RAILS_ENV=production

c:
cd \sandelys2
net start "PostgreSQL Database Server 8.3"
ruby script\server
net stop "PostgreSQL Database Server 8.3"
endlocal
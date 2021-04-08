docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=bonelf@123" -u 0:0 -p 1433:1433 --name sqlserver -v /www/server/docker-srv/sqlserver/data:/var/opt/mssql -d mcr.microsoft.com/mssql/server:2019-latest

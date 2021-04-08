docker run --name postgres -v /www/server/docker-srv/postgresql/data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=567215 -d -p 5432:5432 postgres:12.6

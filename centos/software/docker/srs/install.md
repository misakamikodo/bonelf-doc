[官方地址](https://github.com/ossrs/srs-docker)

```shell
docker run --name srs -p 1935:1935 -p 1985:1985 -p 8499:8080 ossrs/srs:v3.0-r3

docker cp -a srs:/usr/local/srs/conf /www/server/docker-srv/srs/conf
docker cp -a srs:/usr/local/srs/objs /www/server/docker-srv/srs/objs

docker rm -f srs

docker run --name srs -p 1935:1935 -p 1985:1985 -p 8499:8080 \
--name srs \
-v /www/server/docker-srv/srs/conf/:/usr/local/srs/conf/ \
-v /www/server/docker-srv/srs/objs/:/usr/local/srs/objs/ \
ossrs/srs:v3.0-r3 \
./objs/srs -c conf/srs.my.conf
```
-v /www/server/docker-srv/srs/conf:/usr/local/srs/conf
-v /path/of/yours.conf:/usr/local/srs/conf/srs.conf

rtmp://localhost:1935/live/livestream

http://localhost:8080/live/livestream.flv

http://localhost:8080/live/livestream.m3u8

  rtmp://localhost/live

  livestream
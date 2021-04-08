[官方地址](https://github.com/ossrs/srs-docker)

```shell
docker run --name srs -p 1935:1935 -p 1985:1985 -p 8499:8080 ossrs/srs:v3.0-r3

 -v /path/of/yours.conf:/usr/local/srs/conf/srs.conf 

```

rtmp://localhost/live/livestream
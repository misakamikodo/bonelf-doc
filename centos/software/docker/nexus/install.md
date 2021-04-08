# 安装
```shell

docker pull sonatype/nexus3:3.29.2

sudo docker run -d --restart always --name nexus3 -v /www/server/docker-srv/nexus/data:/sonatype-work -p 8199:8081 sonatype/nexus3:3.29.2

```
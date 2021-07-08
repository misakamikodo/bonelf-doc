复制配置文件到目录
```shell
docker rm seata

docker run --name seata -p 8091:8091 -d  seataio/seata-server:1.4.0

docker cp seata:/seata-server/resources/  ./seata-config/

docker stop seata && docker rm seata
```
替换 register.conf

移动 nacos-seata到seata-config

```shell
yum install -y dos2unix #可选
dos2unix nacos-config.sh #可选

bash nacos-config.sh -h 172.17.0.1 -p 8848 -g SEATA_GROUP -u nacos -w nacos # -t namespace
```

开发8091端口

seata-spring-boot-starter+spring-cloud-starter-alibaba-seata包的问题（应该有解决办法）：
1.项目中spring.cloud.nacos.discovery.group=SEATA_GROUP（和seata服务一样）
2.
seata-spring-boot-starter 1.4.0 包中 service.vgroup_mapping 不是对于config.txt的service.vgroupMapping，请在nacos中重新添加配置
3.
seata-spring-boot-starter 1.4.0 包中 写死了seata的服务名称为 serverAddr 请不要该seata的服务明显为网上常见的seata-server或者server-seata
4.
seata-spring-boot-starter 1.4.0 包中 
写死了seata的group为 DEFAULT_GROUP（我开始觉得我可能有配置的错误了），所以先把group设为DEFAULT_GROUP
但是在读取配置时又是从SEATA_GROUP中读取.. 这意味着需要DEFAULT_GROUP和SEATA_GROUP都有配置并且seata启动在DEFAULT_GROUP中？

解决办法：配置读SEATA_GROUP  注册在DEFAULT_GROUP

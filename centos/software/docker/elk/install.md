复制驱动包（可选），也可以映射

```shell
docker exec -it logstash /bin/bash
cd ../../..
cd /usr/share/logstash/config
mkdir mysql
exit
docker cp /www/server/docker-srv/elk/logstash/mysql-connector-java-8.0.11.jar logstash:/usr/share/logstash/config/mysql/mysql-connector-java-8.0.11.jar
```

## logstash

来源file，syslog,beats 只能选择其中一种

注意： index 必须小写（lower case）

## 示例

下面的已怕配置到域名解析和nginx；

kibana 5061：http://kibana.bonelf.com/app/home#/

kibana结果：http://kibana.bonelf.com/app/management/data/index_management/indices

elasticsearch: http://elasticsearch.bonelf.com/bonelfSpu/_search?pretty

删除索引（index）：curl -XDELETE -u elastic:changeme http://elasticsearch.bonelf.com/(index)
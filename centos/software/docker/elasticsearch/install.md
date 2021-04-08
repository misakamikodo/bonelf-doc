搜索服务
如果需要为es和Kafka等创建网络
docker network create esnet
```shell
docker pull docker.elastic.co/elasticsearch/elasticsearch:7.9.3@sha256:9116cf5563a6360ed204cd59eb89049d7e2ac9171645dccdb1421b55dbae888b
```

9200是供http访问端口，9300是供tcp访问的端口（ --network esnet 对照上面的创建网络，bdaab402b220，容器的镜像（docker images查看））
docker run --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:none

安装分词
```shell
docker exec -it elasticsearch /bin/bash
./bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.9.3/elasticsearch-analysis-ik-7.9.3.zip
./bin/elasticsearch-plugin install https://github.rc1844.workers.dev/medcl/elasticsearch-analysis-ik/releases/download/v7.9.3/elasticsearch-analysis-ik-7.9.3.zip
# (退出重启)
exit
docker restart elasticsearch
```
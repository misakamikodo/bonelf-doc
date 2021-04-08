cmd.txt为以前的错误安装经历
```shell
git clone  https://github.com/foxiswho/docker-rocketmq.git

cd docker-rocketmq/rmq

(vi docker-compose.yml)

chmod +x start.sh

./start.sh

docker run -d -v $(pwd)/logs:/home/rocketmq/logs \
--name rmqnamesrv \
-e "JAVA_OPT_EXT=-Xms512M -Xmx512M -Xmn128m" \
-p 9876:9876 \
foxiswho/rocketmq:4.8.0 \
sh mqnamesrvdocker run --name rmqnamesrv --restart=always -d -p 9876:9876 -v /root/docker-srv/rocketmq/namesrv/logs:/home/rocketmq/logs -e "MAX_POSSIBLE_HEAP=100000000" rocketmqinc/rocketmq:4.4.0 sh mqnamesrv

docker run -d  -v $(pwd)/logs:/home/rocketmq/logs -v $(pwd)/store:/home/rocketmq/store \
-v $(pwd)/conf:/home/rocketmq/conf \
--name rmqbroker \
-e "NAMESRV_ADDR=rmqnamesrv:9876" \
-e "JAVA_OPT_EXT=-Xms512M -Xmx512M -Xmn128m" \
-p 10911:10911 -p 10912:10912 -p 10909:10909 \
foxiswho/rocketmq:4.8.0 \
sh mqbroker -c /home/rocketmq/conf/broker.conf

docker run --name rmqconsole --link rmqserver:rmqserver \
-e "JAVA_OPTS=-Drocketmq.namesrv.addr=rmqserver:9876 -Dcom.rocketmq.sendMessageWithVIPChannel=false" \
-p 8180:8080 -t styletang/rocketmq-console-ng
```

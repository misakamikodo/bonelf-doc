```shell
docker image rm ;
docker rmi 
docker rm 
docker run
docker stop
docker ps -a  # -a查所有 不加查启动的
docker run -d --name= XX
docker update \[name] --restart=always
docker logs -f -t --tail 20 mqbroker-n0
docker exec -it 40c330755e61 /bin/bash
docker cp XXX XXX:XXX
docker logs -f container
docker inspect --format='{{.NetworkSettings.IPAddress}}' container  # 看IP
```
## 打开tcp 端口（可支持idea docker部署）

```shell
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/tcp.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375
EOF

```

pom里添加 docker 插件

右侧maven plugins 跑 docker build

后 idea->services窗口->+ run configuration type->docker->右键images里 create container 

run-option: 
-p 8800:8800 端口映射 
--network bonelfnet 设置一个网段(docker network create bonelfnet)
-v /.../XXX.jar:/XXX.jar 创建jar包映射，更新jar包来更新

如果想执行mvn deploy 注意需要：

-DskipDockerBuild 跳过 build 镜像

-DskipDockerTag 跳过 tag 镜像

-DskipDockerPush 跳过 push 镜像

-DskipDocker 跳过整个阶段

##删除 空悬镜像
```shell
$ docker rmi $(docker images -f "dangling=true" -q)

# 检查一下，已经没有<none>的镜像了。
$ docker images | grep 'none'
```
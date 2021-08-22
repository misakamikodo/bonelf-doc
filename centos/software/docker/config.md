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

run-option: -p 8800:8800 端口映射 --network bonelfnet 设置一个网段(docker network create bonelfnet)
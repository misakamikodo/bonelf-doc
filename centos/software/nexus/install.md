# 安装

去官网下载，版本自定义 nexus-3.29.2-02-unix.tar.gz

```shell

tar -zcvf wget nexus-3.29.2-02-unix.tar.gz

vi nexus-3.29.2-02/etc/nexus-default.properties #找到application-port 修改端口号

cp nexus.service /usr/lib/systemd/system/nexus.service # 注册为服务

systemctl start nexus # 启动

systemctl enable nexus # 开机启动

```
#centos 常用命令

##必要工具

```shell
yum install git #安装git
yum install unzip #zip 解压缩
```

##常用基本命令/usr/local/bind/sbin/named -n 1 -u named -c /usr/local/bind/etc/named.conf

```shell
tar zxvf xx.tar.gz #解压缩
tar -zcvf xx.tar.gz /xx #压缩
ps -ef|grep \[name] #查进程
nohup java -jar \[name] -xms\[number] ~~~ -> XXX.out & #启动jar包
tail -f \[name].out
top -p \[pid] #查看占用内存 cpu...
netstat -a #列出端口、路由
lsof -i tcp:\[port] #端口占用
ldd \[file] #查看程序关联的动态链接库
sed -e 4a\\[string] \[file] #在第四行后添加新字符串 
: > \[file] #清空文件
yum list | grep -i \[name] # 找包
tee \[file] # 逐行写文件 使用 EOF 命令终止

# 查软件
rpm -qa git
# 查目录
rpm -ql git-2.27.0-1.el8.x86_64
```

##服务
```shell

systemctl start \[]
systemctl enable \[]
systemctl stop \[]
systemctl restart \[]
systemctl disable \[]
systemctl daemon-reload

```

##zip命令

##git命令
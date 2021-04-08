# 

[bind智能DNS + bindUI管理系统](https://blog.csdn.net/weixin_30820151/article/details/95735567)

```shell
wget http://ftp.isc.org/isc/bind9/9.11.20/bind-9.11.20.tar.gz #因为我用yum install bind安装时是这个版本

#解决 not support for mysql的关键
ln -s /www/server/mysql/lib/libmysqlclient.so /usr/lib64/libmysqlclient.so
ln -s /www/server/mysql/lib/libmysqlclient.so /usr/lib/libmysqlclient.so

# bind-9.11.20

# yum install -y bind-utils traceroute wget man sudo ntp ntpdate screen patch make gcc gcc-c++ flex bison zip unzip ftp net-tools --skip-broken

# libcap-devel 别装这个包

tar -zxvf bind-9.11.20.tar.gz

cd bind-9.11.20

#xz -d bind-9.17.0.tar.xz
 
#tar -xvf bind-9.17.0.tar

./configure --prefix=/www/server/bind-dns/bind --with-dlz-mysql=/www/server/mysql --enable-threads --enable-epoll --enable-largefile --with-openssl=yes

  --with-openssl=/usr/local/openssl # 启动报 System fault 什么的，不要 openssl可以（版本不兼容）

make  #报 my_bool 错误 修改dlz_mysql_driver.c

make install

ln -s /www/server/bind-dns/bind /usr/local/bind
ln -s /usr/local/bind/etc /etc/named #没什么用

groupadd -g 25 named
useradd named -M -u 25 -g 25 -s /sbin/nologin
chown -R named:named /usr/local/bind/var
mkdir -p /var/log/named  /usr/local/bind/etc/conf.d
mkdir /usr/local/bind/var/log

vi /usr/local/bind/var/log/query.log /usr/local/bind/var/log/error.log #创建即可

chmod -R 777 /usr/local/bind/var/log
chown -R named:named /usr/local/bind/var/log
# chown -R named:named /usr/local/bind

cd /usr/local/bind/etc

/usr/local/bind/sbin/rndc-confgen > rndc.conf 
tail -10 rndc.conf | head -9 | sed s/#\ //g > named.conf

#cp named.conf usr/local/bind/etc/named.conf

vi /usr/local/bind/etc/named.conf

cp -r /www/server/bind-dns/bind-ui/pkg/named/conf.d /usr/local/bind/etc

/www/server/bind-dns/bind/sbin/named-checkconf -z /usr/local/bind/etc/named.conf

#vi /etc/profile

#export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:$JAVA_HOME/bin:/www/server/mysql/bin

#systemctl daemon-reload #刷新服务

/usr/local/bind/sbin/named -n 1 -u named -c /usr/local/bind/etc/named.conf -g # 调试运行

vi /usr/lib/systemd/system/named.service

```

```shell

systemctl start named

systemctl enable named

vi /etc/resolv.conf #配置DNS

```
添加
```text
nameserver 127.0.0.1
```

#如果发现不行 使用安装好的bind-bak.tar.gz替换/www/server/bind-dns/bind

```





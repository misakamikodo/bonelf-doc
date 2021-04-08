# 

参考：[bind安装](https://www.jianshu.com/p/3d9d41521f82)

```shell
vi /etc/ld.so.conf                        # 添加如下内容
ln -s /www/server/mysql/lib/libmysqlclient.so /usr/lib64

include /etc/ld.so.conf.d/*.conf
/usr/local/lib
#下面的增加的，实际上只要libmysqlclient.so
/usr/local/lib64
/lib
/lib64
/usr/lib
/usr/lib64
#保证上面的目录有libmysqlclient.so 或者超链接

ldconfig

./configure --with-dlz-mysql=yes --enable-threads --enable-epoll --enable-largefile

yum install bind-sdb

/usr/sbin/named -V # 吐了，看到确实使用了--with-dlz-mysql，还以为这种安装方式不会支持

/usr/sbin/rndc-confgen > rndc.conf 
tail -10 rndc.conf | head -9 | sed s/#\ //g > named.conf

vim /etc/named.conf 

cp -r /www/server/bind-dns/bind-ui/pkg/named/conf.d /etc/named

ln -sf /www/server/mysql/libmysqlclient* /usr/local/mysql/lib/mysql/

systemctl start named-sdb

systemctl enable named-sdb

vi /etc/resolv.conf #配置DNS

```
nameserver:127.0.0.1

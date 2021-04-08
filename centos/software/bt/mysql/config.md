mysql -uroot -p　连接数据库 bonelf@123

宝塔安装的MySQL root不允许外部ip访问，为了方便新建一个最高权限用户
8.0+:
```shell

use mysql 

update user set host="%" where user="root";

flush privileges;

```
5.0+:
# 新建并授权bonelf用户对所有数据库在任何ip都可以进行操作
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'bonelf@123';
或
grant all on *.* to bonelf@'%' identified by '\[password]' with grant option;
# 刷新数据库
flush privileges;
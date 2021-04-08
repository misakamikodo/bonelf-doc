3.进入镜像配置
```shell
docker exec -it oracle11g bash

su root;
```
密码:helowin

编辑环境变量:
```shell
vi /etc/profile
```

```text
export ORACLE_HOME=/home/oracle/app/oracle/product/11.2.0/dbhome_2
export ORACLE_SID=helowin
export PATH=$ORACLE_HOME/bin:$PATH
```

创建软连接
```shell
ln -s $ORACLE_HOME/bin/sqlplus /usr/bin

source /etc/profile
```

切换到oracle 用户
```shell
sqlplus /nolog

conn /as sysdba
```

(1容器内 ``` cd /var/tmp --> chown oracle:dba .oracle ```解决权限问题)
(2容器内 ``` su - oracle ```解决权限问题)

接着执行下面命令

```oracle
alter user system identified by 567215;

alter user sys identified by sys;
```




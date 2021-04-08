
```shell
docker exec -it mongo mongo admin
```
```shell
# 创建一个名为 admin，密码为 123456 的用户。
db.createUser({ user:'admin',pwd:'567215',roles:[ { role:'userAdminAnyDatabase', db: 'admin'},"readWriteAnyDatabase"]});
# 尝试使用上面创建的用户信息进行连接。
db.auth('admin', '567215')
```


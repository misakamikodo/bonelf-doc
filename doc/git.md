##删除文件 本地不删除

```shell
git rm -r --cached .idea
```

##删除文件和历史记录

一定使用git bash 至少使用idea终端没用

```shell
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch 相对根目录的路径' --prune-empty --tag-name-filter cat -- --all

git push gitee --force --all

git push gitee --force --tags  #可选

git for-each-ref --format='delete %(refname)' refs/original | git update-ref --stdin
git reflog expire --expire=now --all
git gc --prune=now


```
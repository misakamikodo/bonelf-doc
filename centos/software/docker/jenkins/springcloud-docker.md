这块暂时想不到怎么做，如果用docker部署使用 mvn docker:build可以创建镜像，但是大部分需要的是更新jar包和重启镜像操作，

Jenkins容器内应该不能把包移动到容器外，并操作docker重启某个镜像。

（需要解决的问题是 打包->停止spring容器->移动jar包->启动spring容器 能做到没有镜像执行build，没有容器执行run更好）

#1.修改源镜像地址
不如此在安装时报 Error: Failed to download metadata for repo 'XX': Cannot prepare internal mirrorlist: No URLs in mirrorlist
```shell
## 备份系统自带的源镜像地址
$ mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
(mv CentOS-Linux-Extras.repo CentOS-Linux-Extras.repo.bak)
(cp CentOS-Linux-BaseOS.repo CentOS-Linux-BaseOS.repo.bak)
vim CentOS-Linux-BaseOS.repo
baseurl=https://vault.centos.org/centos/$releasever/BaseOS/$basearch/os/
(mv CentOS-Linux-PowerTools.repo CentOS-Linux-PowerTools.repo.bak)
(mv CentOS-Linux-AppStream.repo CentOS-Linux-AppStream.repo.bak)
## 下载阿里云的源镜像地址(注意centos版本号 7或8)
$ wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
## 8的版本Centos-8.repo已下线（虽然repo还在）
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo
## 生成缓冲
$ yum makecache
```

###关于防火墙的原因（nftables后端兼容性问题，产生重复的防火墙规则）
```text
Theiptablestooling can act as a compatibility layer, behaving like iptables but actually configuring nftables.
 This nftables backend is not compatible with the current kubeadm packages:
  it causes duplicated firewall rules and breakskube-proxy.

```
###关于selinux的原因（关闭selinux以允许容器访问宿主机的文件系统）
```text
Setting SELinux in permissive mode by runningsetenforce 0andsed ...effectively disables it. 
This is required to allow containers to access the host filesystem, which is needed by pod networks for example.
You have to do this until SELinux support is improved in the kubelet.
```
###不止要关闭防火墙，一般还需要关闭swap、selinux
```text
1.Swap会导致docker的运行不正常，性能下降，是个bug，但是后来关闭swap就解决了，就变成了通用方案，后续可能修复了(我没关注)，
基本上默认关闭了就OK，内存开大点儿不太会oom，本来容器也可以限制内存的使用量，控制一下就好。
2.Selinux是内核级别的一个安全模块，通过安全上下文的方式控制应用服务的权限，是应用和操作系统之间的一道ACL，
但不是所有的程序都会去适配这个模块，不适配的话开着也不起作用，何况还有规则影响到正常的服务。比如权限等等相关的问题。
3防火墙看你说的是那种，如果你说的是iptables的话 ，那样应该是开着的，不应该关。k8s通过iptables做pod间流量的转发和端口映射，
如果你说的防火墙是firewalld那就应该关闭，因为firewalld和iptables属于前后两代方案，互斥。当然，如果k8s没用iptables，
比如用了其他的方式那就不需要用到自然可以关掉。
```

#2.关闭、禁用防火墙
```shell
$ systemctl stop firewalld
$ systemctl disable firewalld

# setenforce是Linux的selinux防火墙配置命令， 执行setenforce 0 表示关闭selinux防火墙)
$ setenforce 0
```
#3.需要关闭 swap
```shell
$ swapoff -a
# 注释掉 SWAP 的自动挂载
$ vim /etc/fstab
>>
#/dev/mapper/centos-swap swap                    swap    defaults        0 0
# 使用free -m确认swap已经关闭。swap部分为0
$ free -m
```
#4.创建 /etc/sysctl.d/k8s.conf 文件 (可选)
```shell
$ cd /etc/sysctl.d
$ vim k8s.conf
>>
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness=0
# 使得配置文件生效
$ modprobe br_netfilter
$ sysctl -p /etc/sysctl.d/k8s.conf
```

#安装 kubelet、kubeadm、kubectl
```shell
$ cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

$ yum install -y kubelet kubeadm kubectl
$ systemctl enable --now kubelet  (systemctl start kubelet)
```

##8.google_containers 配置（可以等 kubeadm init 报错时根据版本做 docker pull）
在kubernetes init之前输入以下命令，由于coredns改名为coredns/coredns了
```shell
$ docker pull coredns/coredns:1.8.4
$ docker tag coredns/coredns:1.8.4 registry.aliyuncs.com/google_containers/coredns:v1.8.4
```
=====================================以下为master部分========================================
##9.初始化节点，node 节点可以跳过直接到 step11
```shell
# 如果出错disable swap，执行步骤3 (先看下面可能出现的问题)
$ kubeadm init --pod-network-cidr=10.244.0.0/16 --image-repository=registry.aliyuncs.com/google_containers
# 如果初始化过程出现问题，使用如下命令重置
$ kubeadm reset
$ rm -rf /var/lib/cni/
$ rm -f $HOME/.kube/config
$ systemctl daemon-reload && systemctl restart kubelet
```
The HTTP call equal to 'curl -sSL http://localhost:10248/healthz' failed with error: Get "http://localhost:10248/healthz": dial tcp [::1]:10248: connect: connection refused
问题分析：
之前我的Docker是用yum安装的，docker的cgroup驱动程序默认设置为systemd。默认情况下Kubernetes cgroup为system，我们需要更改Docker cgroup驱动，

解决方法
```shell
# 添加以下内容
vim /etc/docker/daemon.json
{"exec-opts":["native.cgroupdriver=systemd"]}
# 重启docker
systemctl restart docker
# 重新初始化
kubeadm reset # 先重置

kubeadm init XXXX
```

##10.初始化完毕，根据日志提示执 config 命令
```text
example:
To start using your cluster, you need to run the following as a regular user:

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.3.69.72:6443 --token va5ioe.yovvkc002zpz2txv \
--discovery-token-ca-cert-hash sha256:90fc7d96264c7fa6e6e816de44ebf4ae36034d0cef42453d1a01e199502eaac5
me:
To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:
#加入集群命令 记得保存 kubeadm token create --print-join-command 可查询
kubeadm join 192.168.31.60:6443 --token 81l8wu.5b0a8ufsdr7z78b9 \
	--discovery-token-ca-cert-hash sha256:5bf26f5fbc65f0ace29a1d2880ff03423d6177b050689dd4a841ddf3a014eda9
```
根据这个提示安装
```shell
$ HOME = /root
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
还需要部署一个 Pod Network 到集群中，此处选择 flannel
```shell
$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```
=====================================以下为node部分========================================
11.node 安装(集群模式下，单机后面的步骤都不需要了)
重复step1 - step8（包括9出现的问题） 安装 docker kubelet kubeadm kubectl等，不需要init初始化

理论上来说，只需要在master上面操作集群，node上面不能通过kubectl等工具操作集群。

但是希望在node上面通过kubectl操作集群的话，只需要配置master相同的$HOME/.kube/config
```shell
# 在master上，将master中的admin.conf 拷贝到node中,这里是scp的方式，使用客户端手动上传也是可以的
$ scp /etc/kubernetes/admin.conf root@10.11.90.5:/root/

# 在node上
$ HOME = /root
$ mkdir -p $HOME/.kube
$ sudo cp -i $HOME/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
12.将 node 加到 master 中
```shell
# 在master上面查看kubeadm token
$ kubeadm token list

>>ts699z.y6lmkkn7td2e2lt3

# 如果执行kubeadm token list没有结果，说明token过期了
# 默认情况下，kubeadm生成的token只有24小时有效期，过了时间需要创建一个新的
$ kubeadm token create
# 也可以生成一个永不过期的token，当然这是有安全隐患的
$ kubeadm token create --ttl 0



# 在master上面查看discovery-token-ca-cert-hash
$ openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'

>>90fc7d96264c7fa6e6e816de44ebf4ae36034d0cef42453d1a01e199502eaac5
# 在node上面执行join命令
$ kubeadm join 192.168.31.211:6443 --token k6kicq.5u39ktp0ync504ur \
	--discovery-token-ca-cert-hash sha256:2269c7170f2393fde075ab454c0650ff5e29a51821d9c37c359a98974daaca7f
```

13.master 节点验证集群及组件，命令查看集群信息
```shell
$ kubectl get nodes
k8s删除添加node节点

# 查看节点数和删除node节点（master节点）
$ kubectl get node
NAME        STATUS     ROLES                  AGE   VERSION
ebgmaster   Ready      control-plane,master   37d   v1.22.0
ebgnode1    Ready      <none>                 37d   v1.22.0
ebgnode2    NotReady   <none>                 37d   v1.22.0
# 删除节点
$ kubectl  delete nodes ebgnode2
登陆node节点宿主机,在被删除的node节点清空集群信息

$ kubeadm reset
[reset] WARNING: Changes made to this host by 'kubeadm init' or 'kubeadm join' will be reverted.
[reset] Are you sure you want to proceed? [y/N]: y
[preflight] Running pre-flight checks
W0924 17:09:23.935058   92357 removeetcdmember.go:80] [reset] No kubeadm config, using etcd pod spec to get data directory
[reset] No etcd config found. Assuming external etcd
[reset] Please, manually reset etcd to prevent further issues
[reset] Stopping the kubelet service
[reset] Unmounting mounted directories in "/var/lib/kubelet"
[reset] Deleting contents of config directories: [/etc/kubernetes/manifests /etc/kubernetes/pki]
[reset] Deleting files: [/etc/kubernetes/admin.conf /etc/kubernetes/kubelet.conf /etc/kubernetes/bootstrap-kubelet.conf /etc/kubernetes/controller-manager.conf /etc/kubernetes/scheduler.conf]
[reset] Deleting contents of stateful directories: [/var/lib/kubelet /var/lib/dockershim /var/run/kubernetes /var/lib/cni]

The reset process does not clean CNI configuration. To do so, you must remove /etc/cni/net.d

The reset process does not reset or clean up iptables rules or IPVS tables.
If you wish to reset iptables, you must do so manually by using the "iptables" command.

If your cluster was setup to utilize IPVS, run ipvsadm --clear (or similar)
to reset your system's IPVS tables.

The reset process does not clean your kubeconfig files and you must remove them manually.
Please, check the contents of the $HOME/.kube/config file.
```
error: the server doesn't have a resource type "nodes"
/etc/kubernetes/目录下的文件生成日期。果然admin.conf 配置还是久远前的创建日期。
```shell
mv admin.conf admin.conf.bak
执行：
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
```

master 找不到 node
```shell
hostnamectl --static set-hostname k8s-master  # master
hostname $hostname
hostnamectl --static set-hostname k8s-node1  # node
hostname $hostname
重新init join 即可
```

#命令
```shell
[root@master1 ~]# kubectl get secret -n kube-system |grep admin|awk '{print $1}'
dashboard-admin-token-bwgjv
# 复制下面的 token
[root@master1 ~]# kubectl describe secret dashboard-admin-token-bwgjv -n kube-system|grep '^token'|awk '{print $2}'
eyJhbGciO？？？
```

#ui界面
[dashbord](https://github.com/kubernetes/dashboard/releases)
```shell
#ip 需要通过raw.githubusercontent.com ping
echo "185.199.110.133 raw.githubusercontent.com" >> /etc/hosts
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.1/aio/deploy/recommended.yaml

#查看
kubectl get pods --all-namespaces

#删除现有的dashboard服务，dashboard 服务的 namespace 是 
#kubernetes-dashboard，但是该服务的类型是ClusterIP，不便于我们通过浏览器访问，因此需要改成NodePort型的
kubectl delete service kubernetes-dashboard --namespace=kubernetes-dashboard

kubectl apply -f 包中两个yaml

kubectl get secret -n kubernetes-dashboard |grep admin|awk '{print $1}'
dashboard-admin-token-72fxb
kubectl describe secret dashboard-admin-token-72fxb -n kubernetes-dashboard|grep '^token'|awk '{print $2}'

#查错误原因
kubectl describe pod kubernetes-dashboard-xxx(pod name) -n kubernetes-dashboard
```

增加用户：
```shell
kubectl create namespace bonelf
kubectl create serviceaccount bonelf-admin -n bonelf
kubectl create rolebinding bonelf-admin -n bonelf --clusterrole=cluster-admin --serviceaccount=bonelf:bonelf-admin

kubectl get secret -n bonelf
```

X node(s) had taint {node.kubernetes.io/not-ready: }, that the pod didn't tolerate
node.kubernetes.io/not-ready：节点未准备好。这相当于节点状态 Ready 的值为 "False"。
node.kubernetes.io/unreachable：节点控制器访问不到节点. 这相当于节点状态 Ready 的值为 "Unknown"。
node.kubernetes.io/memory-pressure：节点存在内存压力。
node.kubernetes.io/disk-pressure：节点存在磁盘压力。
node.kubernetes.io/pid-pressure: 节点的 PID 压力。
node.kubernetes.io/network-unavailable：节点网络不可用。
node.kubernetes.io/unschedulable: 节点不可调度。
node.cloudprovider.kubernetes.io/uninitialized：如果 kubelet 启动时指定了一个 "外部" 云平台驱动， 它将给当前节点添加一个污点将其标志为不可用。在 cloud-controller-manager 的一个控制器初始化这个节点后，kubelet 将删除这个污点。

```shell
systemctl status kubelet
```
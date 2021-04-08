[Centos7.x 安装Openvpn详解](https://www.fandenggui.com/post/centos7-install-openvpn.html)
# 安装 (2.4.10)
```shell
yum install -y epel-release openssl lzo pam openssl-devel lzo-devel pam-devel easy-rsa openvpn

yum install -y epel-release 
yum update -y
yum install -y openssl lzo pam openssl-devel lzo-devel pam-devel
yum install -y easy-rsa
yum install -y openvpn
```
#配置证书密钥
```shell
cp -rf /usr/share/easy-rsa/3.0.8 /etc/openvpn/server/easy-rsa
cd /etc/openvpn/server/easy-rsa
./easyrsa init-pki
-> yes
./easyrsa build-ca nopass
-> bonelf
./easyrsa build-server-full server nopass
./easyrsa build-client-full client1 nopass
./easyrsa build-client-full client2 nopass
......
./easyrsa gen-dh
openvpn --genkey --secret ta.key
```
#配置 Server 端
##创建使用的目录
```shell
# 日志存放目录
mkdir -p /var/log/openvpn/
# 用户管理目录
mkdir -p /etc/openvpn/server/user
# 配置权限
chown openvpn:openvpn /var/log/openvpn
```
##创建Server配置文件
```shell
vi /etc/openvpn/server/server.conf
```
```text
#################################################
# This file is for the server side              #
# of a many-clients <-> one-server              #
# OpenVPN configuration.                        #
#                                               #
# Comments are preceded with '#' or ';'         #
#################################################
port 1194
proto tcp-server
## Enable the management interface
# management-client-auth
# management localhost 7505 /etc/openvpn/user/management-file
dev tun     # TUN/TAP virtual network device
user openvpn
group openvpn
ca /etc/openvpn/server/easy-rsa/pki/ca.crt
cert /etc/openvpn/server/easy-rsa/pki/issued/server.crt
key /etc/openvpn/server/easy-rsa/pki/private/server.key
dh /etc/openvpn/server/easy-rsa/pki/dh.pem
tls-auth /etc/openvpn/server/easy-rsa/ta.key 0
## Using System user auth.
# plugin /usr/lib64/openvpn/plugins/openvpn-plugin-auth-pam.so login
## Using Script Plugins
script-security 3
# sh /etc/openvpn/server/user/checkpsw.sh
auth-user-pass-verify /etc/openvpn/server/user/checkpsw.sh via-env
# client-cert-not-required  # Deprecated option
verify-client-cert
username-as-common-name
## Connecting clients to be able to reach each other over the VPN.
client-to-client
## Allow multiple clients with the same common name to concurrently connect.
duplicate-cn
# client-config-dir /etc/openvpn/server/ccd
# ifconfig-pool-persist ipp.txt
server 10.8.0.0 255.255.255.0
# server 10.8.0.0 255.255.255.0
push "dhcp-option DNS 114.114.114.114"
push "dhcp-option DNS 1.1.1.1"
push "route 10.93.0.0 255.255.255.0"
# comp-lzo - DEPRECATED This option will be removed in a future OpenVPN release. Use the newer --compress instead.
compress lzo
# cipher AES-256-CBC
ncp-ciphers "AES-256-GCM:AES-128-GCM"
## In UDP client mode or point-to-point mode, send server/peer an exit notification if tunnel is restarted or OpenVPN process is exited.
# explicit-exit-notify 1
keepalive 10 120
persist-key
persist-tun
verb 3
log /var/log/openvpn/server.log
log-append /var/log/openvpn/server.log
status /var/log/openvpn/status.log
```
注意！！！ 这里创建完配置文件后，需要做个配置文件的软连接，因为当前版本的 openvpn systemd 启动文件中读取的是.service.conf配置。
```shell
cd /etc/openvpn/server/
ln -sf server.conf .service.conf
```
##创建用户密码文件
格式是```text 用户 密码```以空格分割即可
```shell
tee /etc/openvpn/server/user/psw-file << EOF
admin 567215
bonelf 567215
(mytest mytestpass)
(...)
EOF
chmod 600 /etc/openvpn/server/user/psw-file
chown openvpn:openvpn /etc/openvpn/server/user/psw-file
```
##创建密码检查脚本
```shell
vi /etc/openvpn/server/user/checkpsw.sh
```
```text
#!/bin/sh
###########################################################
# checkpsw.sh (C) 2004 Mathias Sundman <mathias@openvpn.se>
#
# This script will authenticate OpenVPN users against
# a plain text file. The passfile should simply contain
# one row per user with the username first followed by
# one or more space(s) or tab(s) and then the password.
PASSFILE="/etc/openvpn/server/user/psw-file"
LOG_FILE="/var/log/openvpn/password.log"
TIME_STAMP=`date "+%Y-%m-%d %T"`
###########################################################
if [ ! -r "${PASSFILE}" ]; then
  echo "${TIME_STAMP}: Could not open password file \"${PASSFILE}\" for reading." >>  ${LOG_FILE}
  exit 1
fi
CORRECT_PASSWORD=`awk '!/^;/&&!/^#/&&$1=="'${username}'"{print $2;exit}' ${PASSFILE}`
if [ "${CORRECT_PASSWORD}" = "" ]; then
  echo "${TIME_STAMP}: User does not exist: username=\"${username}\", password=
\"${password}\"." >> ${LOG_FILE}
  exit 1
fi
if [ "${password}" = "${CORRECT_PASSWORD}" ]; then
  echo "${TIME_STAMP}: Successful authentication: username=\"${username}\"." >> ${LOG_FILE}
  exit 0
fi
echo "${TIME_STAMP}: Incorrect password: username=\"${username}\", password=
\"${password}\"." >> ${LOG_FILE}
exit 1
```
```shell
chmod +x /etc/openvpn/server/user/checkpsw.sh
```
##防火墙配置
```shell
firewall-cmd --permanent --add-masquerade #启用ipv4伪装（启动端口转发的前提）
firewall-cmd --permanent --add-service=openvpn
# 或者添加自定义端口
# firewall-cmd --permanent  --add-port=1194/tcp
firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
firewall-cmd --reload
```
##启动服务
```shell
# 查看service名
rpm -ql openvpn |grep service

/usr/lib/systemd/system/openvpn-client@.service
/usr/lib/systemd/system/openvpn-server@.service
/usr/lib/systemd/system/openvpn@.service
# 启动
systemctl start openvpn-server@.service.service
systemctl enable openvpn-server@.service.service
```
#配置客户端
从server上将生成的ca.crt、client1.crt、client1.key、ta.key文件下载到客户端，客户端配置内容D:\Program Files\OpenVPN\config\client.ovpn如下：
/etc/openvpn/server/easy-rsa/pki/issued/client1.crt
/etc/openvpn/server/easy-rsa/pki/private/client1.key
/etc/openvpn/server/easy-rsa/ta.key
/etc/openvpn/server/easy-rsa/pki/ca.crt
```text
# (2.4.8) 保持特性号一致
client
proto tcp-client
dev tun
auth-user-pass
;remote [IP/domain] [port] 此处通过内网穿透到外网
remote 192.168.31.60 1194
ca ca.crt
cert client1.crt
key client1.key
tls-auth ta.key 1
remote-cert-tls server
auth-nocache
persist-tun
persist-key
compress lzo  #comp-lzo (2.3)
verb 4
mute 10
```
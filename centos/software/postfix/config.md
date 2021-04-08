# 邮箱服务配置

[参考](https://cloud.tencent.com/developer/labs/lab/10096)

使用bindui配置 MX 域名解析

```shell
yum -y install postfix dovecot

yum -y install mailx

yum install telnet -y

vi /etc/postfix/main.rf
(postconf -e 'myhostname = server.yourdomain.com')

```

```text
myhostname = mail.bonelf.com
mydomain = bonelf.com
myorigin = $mydomain
## 取消注释并将 inet_interfaces 设置为 all##
inet_interfaces = all
## 更改为 all ##
inet_protocols = all
## 注释 ##
#mydestination = $myhostname, localhost.$mydomain, localhost
## 取消注释 ##
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
## 取消注释并添加 IP 范围 (局域网，vpn，本地)##
mynetworks = 192.168.31.0/24,10.8.0.0/8,127.0.0.0/8
## 取消注释 ##
home_mailbox = Maildir/
```

```shell

useradd me #测试用户

passwd me

->567215

#邮件示例
telnet localhost smtp # 测试
ehlo localhost # telnet中使用

mail from:<centos>
-> 250 2.1.0 Ok
rcpt to:<me>
-> 250 2.1.5 Ok
data
-> 354 End data with <CR><LF>.<CR><LF>
Hello, Welcome to my mailserver (Postfix)
.
-> 250 2.0.0 Ok: queued as B56BF1189BEC
quit
-> 221 2.0.0 Bye
-> Connection closed by foreign host

#邮件文件
ls /home/me/Maildir/new
-> 1617627461.V803I4cd1b8M318001.MiWiFi-R3-srv
cat /home/me/Maildir/new/1617627461.V803I4cd1b8M318001.MiWiFi-R3-srv

#日志
tail -f /var/log/maillog

vi /etc/postfix/master.cf 文件，将如下两行前的 # 去除：

```
```text
smtps inet n - n - - smtpd
-o smtpd_tls_wrappermode=yes
```

打开 /etc/dovecot/dovecot.conf 文件，在最下方加入以下配置：
```text

ssl_cert = </etc/pki/dovecot/certs/dovecot.pem
ssl_key = </etc/pki/dovecot/private/dovecot.pem

protocols = imap pop3 lmtp
listen = *
mail_location = Maildir:~/Maildir
disable_plaintext_auth = no
```

修改 10-master.conf
打开 /etc/dovecot/conf.d/10-master.conf 文件，找到 service auth 部分，将以下行前面的 # 去除：

```text
unix_listener /var/spool/postfix/private/auth {  
       mode = 0666  
}
```
测试
```shell
su me
echo "Mail Content" | mail -s "Mail Subject" ccykirito@163.com
```
# 添加用户

```shell
useradd xxx

passwd xxx

->?????
```

# 登录

示例:

服务器类型：`POP3`
邮箱账户：  `me@bonelf.com`

收件(POP3)服务器：  `bonelf.com`
端口：              `995`
安全连接(SSL)：     `是`
用户名：            `me`
密码：              `567215`

发件(SMTP)服务器：  `bonelf.com`
端口：              `465`
安全连接(SSL)：     `是`
用户名：            `me`
密码：              `567215`

如果使用的时自建的bind(或者dnsmasq) DNS服务器，邮箱不能发送到别的服务器，别的服务器不接受这个非法域名。
```text
550 Domain may not exist or DNS check failed
```

测试无误后：
```shell
systemctl enable postfix

systemctl enable dovecot
```
```shell
#复制client1的内容 到 /etc/openvpn/client

openvpn --daemon --config client.ovpn

rpm -ql openvpn |grep service

openvpn /etc/openvpn/client/client.ovpn

#systemctl start openvpn-client@.service.service

#systemctl enable openvpn-client@.service.service

yum install -y expect
```

connect-vpn.sh

```shell
cd /etc/openvpn/client
openvpn client.ovpn
```

connect-vpn-auto.sh

```shell
#!/usr/bin/expect -f
spawn ./connect-vpn.sh
expect "Enter Auth Username"
send -- "bonelf\n"
expect "Enter Auth Password"
send -- "567215\n"
interact
```

```shell
chmod -777 ./connect-vpn.sh ./connect-vpn-auto.sh

./connect-vpn-auto.sh
```
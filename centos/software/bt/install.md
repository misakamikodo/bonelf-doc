#宝塔安装

yum install -y wget && wget -O install.sh http://download.bt.cn/install/install_6.0.sh && sh install.sh

* 再通过宝塔安装必要的基础服务、工具：
nginx、mysql(init安装)
redis、docker、tomcat(自行安装)

个人喜好必备应用不使用docker （目前有nginx、php、redis、bind、postfix、dovecot、openvpn）
其他使用docker

bt default命令查看网站
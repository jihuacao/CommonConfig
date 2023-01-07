IP=$1 # service ip
ssPort=$2 # port for shadowsocks
kcptunPort=$3 # port for kcptun
proxyPorts=$4 # proxyPorts:proxyPorte-->kcptunPort
proxyPorte=$5

apt -y install python
apt -y install python-pip
pip install --upgrade pip
pip install shadowsocks==2.8.2
sed -i 's/EVP_CIPHER_CTX_cleanup/EVP_CIPHER_CTX_reset/' /usr/local/lib/python2.7/dist-packages/shadowsocks/crypto/openssl.py

now=$(pwd) && cd linux/shadowsocks && python config.py --config_server --server_config_path=/root/ss --server_service_dir=/root/ss --server_port ${ssPort} --server_ip=${IP} && cd ${now}
now=$(pwd) && cd linux/kcptun && python config.py --config_server --server_executable_dir=/root/kcptun --server_config_path=/root/kcptun --server_service_dir=/root/kcptun --server_target_port ${ssPort} --server_listen_port ${kcptunPort} --server_target_ip=${IP} && cd ${now}

cp /root/ss/shadowsocks-server.service /etc/systemd/system/
cp /root/kcptun/kcptun-server-${kcptunPort}.service /etc/systemd/system/
chmod +x /root/kcptun/server_linux_amd64

systemctl daemon-reload
systemctl enable shadowsocks-server.service
systemctl enable kcptun-server-${kcptunPort}.service
systemctl start shadowsocks-server.service
systemctl start kcptun-server-${kcptunPort}.service
systemctl status shadowsocks-server.service
systemctl status kcptun-server-${kcptunPort}.service
# open the ssPort and kcptunPort to accept, iptables --list|grep ${theport} to view the rules
iptables -I INPUT -p tcp --dport ${ssPort} -j ACCEPT
iptables -I INPUT -p udp --dport ${kcptunPort} -j ACCEPT
# proxyPorts:proxyPorte-->kcptunPort, iptables -t nat --list to view the rules, iptables -t nat -D ${type} ${line-number} to delete the rules
iptables -t nat -A PREROUTING -p udp --dport ${proxyPorts}:${proxyPorte} -j REDIRECT --to-ports ${kcptunPort}
# open the proxyPort
iptables -I INPUT -p udp --dport ${proxyPorts}:${proxyPorte} -j ACCEPT
iptables-save

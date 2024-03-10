IP=$1 # service ip
ssPort=$2 # port for shadowsocks
kcptunPort=$3 # port for kcptun
proxyPorts=$4 # proxyPorts:proxyPorte-->kcptunPort
proxyPorte=$5
usage(){
    echo 'help message'
    echo '--ip 指定ss-kcptun服务部署ip'
    echo '--ss_port 指定shadowsocks服务的监听端口'
    echo '--kcptun_port 指定kcptun服务的监听端口'
    echo '--proxy_port_start 指定端口转发起始端口，proxy_port_start:proxy_port_end-->(将会被映射到)kcptun_port'
    echo '--proxy_port_end 指定端口转发结尾端口，proxy_port_start:proxy_port_end-->(将会被映射到)kcptun_port'
    echo '--password 指定密码'
}
ARGS=`getopt \
    -o h\
    --long help, \
    --long ip:: \
    --long ss_port:: \
    --long kcptun_port:: \
    --long proxy_port_start:: \
    --long proxy_port_end:: \
    --long password:: \
    -n 'example.bash' -- "$@"`
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "${ARGS}"
while true ; do
    case "$1" in
        --ip)
            echo "specify ip as $2"; IP=$2; shift 2
            ;;
        --ss_port)
            echo "specify ss_port as $2"; ssPort=$2; shift 2
            ;;
        --kcptun_port)
            echo "specify kcptun_port as $2"; kcptunPort=$2; shift 2
            ;;
        --proxy_port_start)
            echo "specify proxy_port_start as $2"; proxyPorts=$2; shift 2
            ;;
        --proxy_port_end)
            echo "specify proxy_port_end as $2"; proxyPorte=$2; shift 2
            ;;
        --password)
            echo "specify password as $2"; password=$2; shift 2
            ;;
        -h|--help) usage; exit 1;;
        --) shift 1; break;;
        -) shift 1; break;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done
echo "Remaining arguments:"
for arg do
   echo '--> '"\`$arg\`" ;
done

apt update
apt -y install python3
apt -y install python3-pip
python3 -m pip install --upgrade pip
python3 -m pip install shadowsocks==2.8.2
sed -i 's/EVP_CIPHER_CTX_cleanup/EVP_CIPHER_CTX_reset/' /usr/local/lib/python3.8/dist-packages/shadowsocks/crypto/openssl.py

rm -rf ${HOME}/ss-service/
mkdir -p ${HOME}/ss-service/
echo "{" >> ${HOME}/ss-service/ss-service-config.json
echo "    \"port_password\": {" >> ${HOME}/ss-service/ss-service-config.json
echo "        \"${ssPort}\": \"${password}\"" >> ${HOME}/ss-service/ss-service-config.json
echo "    }, " >> ${HOME}/ss-service/ss-service-config.json
echo "    \"timeout\": 300, " >> ${HOME}/ss-service/ss-service-config.json
echo "    \"local_port\": 1080, " >> ${HOME}/ss-service/ss-service-config.json
echo "    \"local_address\": \"127.0.0.1\", " >> ${HOME}/ss-service/ss-service-config.json
echo "    \"fast_open\": false, " >> ${HOME}/ss-service/ss-service-config.json
echo "    \"method\": \"rc4-md5\", " >> ${HOME}/ss-service/ss-service-config.json
echo "    \"server\": \"${IP}\"" >> ${HOME}/ss-service/ss-service-config.json
echo "}" >> ${HOME}/ss-service/ss-service-config.json
echo "[Unit] " >> ${HOME}/ss-service/ss-service.service
echo "Description=shadowsocks Server" >> ${HOME}/ss-service/ss-service.service
echo "After=network.target " >> ${HOME}/ss-service/ss-service.service
echo "[Service] " >> ${HOME}/ss-service/ss-service.service
echo "ExecStart=/usr/local/bin/ssserver -c /root/ss-service/ss-service-config.json" >> ${HOME}/ss-service/ss-service.service
echo "[Install] " >> ${HOME}/ss-service/ss-service.service
echo "WantedBy=multi-user.target " >> ${HOME}/ss-service/ss-service.service
cp ${HOME}/ss-service/ss-service.service /etc/systemd/system/

rm -rf ${HOME}/kcptun-service/
mkdir -p ${HOME}/kcptun-service/
echo "{" >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "    \"target\": \"${IP}:${ssPort}\"," >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "    \"pprof\": false," >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "    \"datashard\": 10," >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "    \"parityshard\": 3," >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "    \"dscp\": 0," >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "    \"quiet\": false," >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "    \"nocomp\": true," >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "    \"sndwnd\": 512," >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "    \"tcp\": false," >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "    \"key\": \"${password}\"," >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "    \"crypt\": \"none\"," >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "    \"mode\": \"fast\"," >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "    \"mtu\": 1350," >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "    \"rcvwnd\": 512," >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "    \"listen\": \":${kcptunPort}\"" >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "}" >> ${HOME}/kcptun-service/kcptun-service-config.json
echo "[Unit] " >> ${HOME}/kcptun-service/kcptun-service.service
echo "Description=Kcptun Server 20001" >> ${HOME}/kcptun-service/kcptun-service.service
echo "After=network.target " >> ${HOME}/kcptun-service/kcptun-service.service
echo "[Service] " >> ${HOME}/kcptun-service/kcptun-service.service
echo "ExecStart=${HOME}/kcptun-service/server_linux_amd64 -c ${HOME}/kcptun-service/kcptun-service-config.json" >> ${HOME}/kcptun-service/kcptun-service.service
echo "[Install] " >> ${HOME}/kcptun-service/kcptun-service.service
echo "WantedBy=multi-user.target" >> ${HOME}/kcptun-service/kcptun-service.service
cp linux/kcptun/server_linux_amd64 ${HOME}/kcptun-service/
chmod +x ${HOME}/kcptun-service/server_linux_amd64
cp ${HOME}/kcptun-service/kcptun-service.service /etc/systemd/system/
#now=$(pwd) && cd linux/kcptun && python config.py --config_server --server_executable_dir=/root/kcptun --server_config_path=${HOME}/kcptun-service --server_service_dir=/root/kcptun --server_target_port ${ssPort} --server_listen_port ${kcptunPort} --server_target_ip=${IP} && cd ${now}


systemctl daemon-reload
#systemctl enable ss-service.service
systemctl enable kcptun-service.service
systemctl stop ss-service.service
systemctl stop kcptun-service.service
#systemctl start ss-service.service
systemctl start kcptun-service.service
systemctl status ss-service.service
systemctl status kcptun-service.service
# open the ssPort and kcptunPort to accept, iptables --list|grep ${theport} to view the rules
iptables -I INPUT -p tcp --dport ${ssPort} -j ACCEPT
iptables -I INPUT -p udp --dport ${kcptunPort} -j ACCEPT
# proxyPorts:proxyPorte-->kcptunPort, iptables -t nat --list to view the rules, iptables -t nat -D ${type} ${line-number} to delete the rules
iptables -t nat -A PREROUTING -p udp --dport ${proxyPorts}:${proxyPorte} -j REDIRECT --to-ports ${kcptunPort}
# open the proxyPort
iptables -I INPUT -p udp --dport ${proxyPorts}:${proxyPorte} -j ACCEPT
iptables-save
apt -y install iptables-persistent
service netfilter-persistent save

# using shadowsocks-libev
sudo snap install shadowsocks-libev
echo "[Unit] " >> ${HOME}/ss-service/sslibev-service.service
echo "Description=shadowsocks-libev Server" >> ${HOME}/ss-service/sslibev-service.service
echo "After=network.target " >> ${HOME}/ss-service/sslibev-service.service
echo "[Service] " >> ${HOME}/ss-service/sslibev-service.service
echo "ExecStart=/snap/bin/shadowsocks-libev.ss-server -s ${IP} -p ${ssPort} -k ${password} -m rc4-md5" >> ${HOME}/ss-service/sslibev-service.service
echo "[Install] " >> ${HOME}/ss-service/sslibev-service.service
echo "WantedBy=multi-user.target " >> ${HOME}/ss-service/sslibev-service.service
cp ${HOME}/ss-service/sslibev-service.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable sslibev-service.service
systemctl stop sslibev-service.service
systemctl start sslibev-service.service
systemctl status sslibev-service.service

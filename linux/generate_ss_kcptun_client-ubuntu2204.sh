remoteIP=""
kcptunRemotePort=""
ssLocalPort=""
kcptunLocalPort=""

usage(){
    echo 'help message'
    echo '--remote_ip 指定远程服务的ip'
    echo '--kcptun_remote_port 指定kcptun服务的监听端口'
    echo '--ss_local_port 指定ss客户端的监听端口，使用网络时，往这个端口传数据'
    echo '--kcptun_local_port 指定kcptun客户端的监听端口，ss客户端会往这个端口传数据'
    echo '--password 指定密码'
}
ARGS=`getopt \
    -o h\
    --long help, \
    --long remote_ip:: \
    --long kcptun_remote_port:: \
    --long ss_local_port:: \
    --long kcptun_local_port:: \
    --long password:: \
    -n 'example.bash' -- "$@"`
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "${ARGS}"
while true ; do
    case "$1" in
        --remote_ip)
            echo "specify remote_ip as $2"; remoteIP=$2; shift 2
            ;;
        --kcptun_remote_port)
            echo "specify kcptun_remote_port as $2"; kcptunRemotePort=$2; shift 2
            ;;
        --kcptun_local_port)
            echo "specify kcptun_local_port as $2"; kcptunLocalPort=$2; shift 2
            ;;
        --ss_local_port)
            echo "specify ss_local_port as $2"; ssLocalPort=$2; shift 2
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
apt -y install python3 python3-pip &&
pip install --upgrade pip &&
pip install shadowsocks==2.8.2
sed -i 's/EVP_CIPHER_CTX_cleanup/EVP_CIPHER_CTX_reset/' /usr/local/lib/python3.10/dist-packages/shadowsocks/crypto/openssl.py
sed -i 's/collections.MutableMapping/collections.abc.MutableMapping/' /usr/local/lib/python3.10/dist-packages/shadowsocks/lru_cache.py

rm -rf ${HOME}/kcptun-client/ &&
mkdir -p ${HOME}/kcptun-client/ &&
cp linux/kcptun/client_linux_amd64 ${HOME}/kcptun-client/ &&
chmod +x ${HOME}/kcptun-client/client_linux_amd64 &&
echo "{" >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "    \"localaddr\": \":${kcptunLocalPort}\"," >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "    \"remoteaddr\": \"${remoteIP}:${kcptunRemotePort}\"," >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "    \"key\": \"renburugou\"," >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "    \"crypt\": \"none\"," >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "    \"mode\": \"fast\"," >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "    \"mtu\": 1350," >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "    \"sndwnd\": 512," >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "    \"rcvwnd\": 512," >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "    \"datashard\": 10," >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "    \"parityshard\": 3," >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "    \"dscp\": 0," >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "    \"nocomp\": true," >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "    \"quiet\": false," >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "    \"tcp\": false," >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "    \"pprof\": false" >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "}" >> ${HOME}/kcptun-client/kcptun-client-config.json &&
echo "[Unit]" >> ${HOME}/kcptun-client/kcptun-client.service &&
echo "Description=kcptun client use visit remote ${remoteIP}:${kcptunRemotePort}" >> ${HOME}/kcptun-client/kcptun-client.service &&
echo "After=network.target" >> ${HOME}/kcptun-client/kcptun-client.service &&
echo "[Service]" >> ${HOME}/kcptun-client/kcptun-client.service &&
echo "ExecStart=${HOME}/kcptun-client/client_linux_amd64 -c ${HOME}/kcptun-client/kcptun-client-config.json" >> ${HOME}/kcptun-client/kcptun-client.service &&
echo "[Install]" >> ${HOME}/kcptun-client/kcptun-client.service &&
echo "WantedBy=multi-user.target" >> ${HOME}/kcptun-client/kcptun-client.service &&
echo "nohup ${HOME}/kcptun-client/client_linux_amd64 -c ${HOME}/kcptun-client/kcptun-client-config.json > ${HOME}/kcptun.log &" >> ${HOME}/start_kcptun_client.sh &&
chmod +x ${HOME}/start_kcptun_client.sh

rm -rf ${HOME}/ss-client/ &&
mkdir -p ${HOME}/ss-client/ &&
echo "{" >> ${HOME}/ss-client/ss-client-config.json &&
echo "    \"timeout\": 300," >> ${HOME}/ss-client/ss-client-config.json &&
echo "    \"local_port\": \"${ssLocalPort}\"," >> ${HOME}/ss-client/ss-client-config.json &&
echo "    \"fast_open\": false," >> ${HOME}/ss-client/ss-client-config.json &&
echo "    \"server\": \"127.0.0.1\"," >> ${HOME}/ss-client/ss-client-config.json &&
echo "    \"server_port\": ${kcptunLocalPort}," >> ${HOME}/ss-client/ss-client-config.json &&
echo "    \"local_address\": \"127.0.0.1\"," >> ${HOME}/ss-client/ss-client-config.json &&
echo "    \"password\": \"renburugou\"," >> ${HOME}/ss-client/ss-client-config.json &&
echo "    \"method\": \"rc4-md5\"" >> ${HOME}/ss-client/ss-client-config.json &&
echo "}" >> ${HOME}/ss-client/ss-client-config.json &&
echo "[Unit]" >> ${HOME}/ss-client/ss-client.service &&
echo "Description=shadowsocks client use kcptun ${kcptunLocalPort}" >> ${HOME}/ss-client/ss-client.service &&
echo "After=network.target" >> ${HOME}/ss-client/ss-client.service &&
echo "[Service]" >> ${HOME}/ss-client/ss-client.service &&
echo "ExecStart=$(which sslocal) -c ${HOME}/ss-client/ss-client-config.json" >> ${HOME}/ss-client/ss-client.service &&
echo "[Install]" >> ${HOME}/ss-client/ss-client.service &&
echo "WantedBy=multi-user.target" >> ${HOME}/ss-client/ss-client.service &&
echo "nohup $(which sslocal) -c ${HOME}/ss-client/ss-client-config.json > ${HOME}/ss-client.log &" >> ${HOME}/start_ss_client.sh &&
chmod +x ${HOME}/start_ss_client.sh

sudo cp ${HOME}/ss-client/ss-client.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl stop ss-client.service
sudo systemctl start ss-client.service
sudo systemctl status ss-client.service
sudo cp ${HOME}/kcptun-client/kcptun-client.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl stop kcptun-client.service
sudo systemctl start kcptun-client.service
sudo systemctl status kcptun-client.service

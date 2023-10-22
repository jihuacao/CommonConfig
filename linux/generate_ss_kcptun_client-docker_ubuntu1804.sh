# 本脚本基于docker构建shadowsocks代理客户端
# 基于bridge网络模式可以实现
#   * container使用代理
#   * host使用代理
# 基于端口转发：iptables -t nat -A PREROUTING -d ${host_ip} -p tcp --dport 1080 -j DNAT --to-destination ${container_ip}:1080可实现
#   * 外部host使用代理
# 使用：
#   * 准备docker环境
#   * 于host中运行此脚本会自动拉去payforsins/ss:latest镜像并构建名为shadowsocks的容器
#     * 相关配置存放于${HOME}/ss-client与${HOME}/kcptun-client中
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
}
ARGS=`getopt \
    -o h\
    --long help, \
    --long remote_ip:: \
    --long kcptun_remote_port:: \
    --long ss_local_port:: \
    --long kcptun_local_port:: \
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

#apt update &&
#apt -y install python3 python3-pip &&
#mkdir -p /root/.pip/ &&
#echo "[global]" >> /root/.pip/pip.conf &&
#echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple"  >> /root/.pip/pip.conf &&
#pip3 install --upgrade pip &&
#pip3 install shadowsocks==2.8.2 &&
#sed -i 's/EVP_CIPHER_CTX_cleanup/EVP_CIPHER_CTX_reset/' /usr/local/lib/python3.6/dist-packages/shadowsocks/crypto/openssl.py

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
echo "WantedBy=multi-user.target" >> ${HOME}/kcptun-client/kcptun-client.service

rm -rf ${HOME}/ss-client/ &&
mkdir -p ${HOME}/ss-client/ &&
echo "{" >> ${HOME}/ss-client/ss-client-config.json &&
echo "    \"timeout\": 300," >> ${HOME}/ss-client/ss-client-config.json &&
echo "    \"local_port\": \"${ssLocalPort}\"," >> ${HOME}/ss-client/ss-client-config.json &&
echo "    \"fast_open\": false," >> ${HOME}/ss-client/ss-client-config.json &&
echo "    \"server\": \"0.0.0.0\"," >> ${HOME}/ss-client/ss-client-config.json &&
echo "    \"server_port\": ${kcptunLocalPort}," >> ${HOME}/ss-client/ss-client-config.json &&
echo "    \"local_address\": \"0.0.0.0\"," >> ${HOME}/ss-client/ss-client-config.json &&
echo "    \"password\": \"renburugou\"," >> ${HOME}/ss-client/ss-client-config.json &&
echo "    \"method\": \"rc4-md5\"" >> ${HOME}/ss-client/ss-client-config.json &&
echo "}" >> ${HOME}/ss-client/ss-client-config.json &&
echo "[Unit]" >> ${HOME}/ss-client/ss-client.service &&
echo "Description=shadowsocks client use kcptun ${kcptunLocalPort}" >> ${HOME}/ss-client/ss-client.service &&
echo "After=network.target" >> ${HOME}/ss-client/ss-client.service &&
echo "[Service]" >> ${HOME}/ss-client/ss-client.service &&
echo "ExecStart=$(which sslocal) -c ${HOME}/ss-client/ss-client-config.json" >> ${HOME}/ss-client/ss-client.service &&
echo "[Install]" >> ${HOME}/ss-client/ss-client.service &&
echo "WantedBy=multi-user.target" >> ${HOME}/ss-client/ss-client.service

echo "nohup sslocal -c /etc/ss-client/ss-client-config.json > /var/ss-client.log &" > ${HOME}/ss-client/start_ss_client.sh
echo "nohup /etc/kcptun-client/client_linux_amd64 -c /etc/kcptun-client/kcptun-client-config.json > /var/kcptun.log" >> ${HOME}/ss-client/start_ss_client.sh

docker pull payforsins/ss:latest
# todo: 这里需要增加判断
docker network create CI
# todo: 这里也需要增加判断
docker run -it --ipc host --network CI --network-alias shadowsocks --name shadowsocks -v ${HOME}/ss-client/:/etc/ss-client/ -v ${HOME}/kcptun-client/:/etc/kcptun-client/ -t payforsins/ss:latest /bin/bash -c "chmod +x /etc/ss-client/start_ss_client.sh && /etc/ss-client/start_ss_client.sh"

#sudo cp ${HOME}/ss-client/ss-client.service /etc/systemd/system/
#sudo systemctl daemon-reload
#sudo systemctl stop ss-client.service
#sudo systemctl start ss-client.service
#sudo systemctl status ss-client.service
#sudo cp ${HOME}/kcptun-client/kcptun-client.service /etc/systemd/system/
#sudo systemctl daemon-reload
#sudo systemctl stop kcptun-client.service
#sudo systemctl start kcptun-client.service
#sudo systemctl status kcptun-client.service

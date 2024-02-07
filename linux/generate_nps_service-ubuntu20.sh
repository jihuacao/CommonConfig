bridgeType="tcp"
authCryptKey=$(date +%s%N |md5sum | cut -c 1-16)
webPasswd=$(date +%s%N |md5sum | cut -c 1-24)
usage(){
    echo 'help message'
    echo '--bridge_ip 指定nps的ip或者host'
    echo '--bridge_port 指定nps的监听端口'
    echo '--web_user 指定nps后端控制用户'
    echo '--web_passwd 指定nps后端控制密码，可随机生成'
    echo '--web_port 指定nps后端控制端口'
}
ARGS=`getopt \
    -o h \
    --long help, \
    --long bridge_ip:: \
    --long bridge_port:: \
    --long web_user:: \
    --long web_passwd:: \
    --long web_port:: \
    -n 'example.bash' -- "$@"`
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "${ARGS}"
while true ; do
    case "$1" in
        --bridge_ip)
            echo "specify bridge_ip as $2"; bridgeIP=$2; shift 2
            ;;
        --bridge_port)
            echo "specify bridge_port as $2"; bidgePort=$2; shift 2
            ;;
        --web_user)
            echo "specify web_user as $2"; webUser=$2; shift 2
            ;;
        --web_passwd)
            echo "specify web_passwd as $2"; webPasswd=$2; shift 2
            ;;
        --web_port)
            echo "specify web_port as $2"; webPort=$2; shift 2
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
cd ~
apt update
apt -y install wget
wget -c https://github.com/ehang-io/nps/releases/download/v0.26.9/linux_amd64_server.tar.gz -O NPSServer.tar.gz
mkdir -p nps-service
tar -xvf NPSServer.tar.gz -C nps-service
cd nps-service

echo "modify nps service config"
sed -i 's/http_proxy_/#http_proxy_/' conf/nps.conf
sed -i 's/https_proxy_/#https_proxy_/' conf/nps.conf

sed -i 's/bridge_type=.*$/bridge_type=tcp/' conf/nps.conf
sed -i 's/bridge_port=.*$/bridge_port=${bridgePort}/' conf/nps.conf
sed -i 's/bridge_ip=.*$/bridge_ip=${bridgeIP}/' conf/nps.conf
sed -i 's/web_user=.*$/web_user=${webUser}/' conf/nps.conf
sed -i 's/web_passwd=.*$/web_passwd=${webPasswd}/' conf/nps.conf
sed -i 's/web_port=.*$/web_port=${webPort}/' conf/nps.conf

echo "generate nps service"
echo "[Unit] " >> ${HOME}/nps-service/nps-service.service
echo "Description=NPS Server" >> ${HOME}/nps-service/nps-service.service
echo "After=network.target " >> ${HOME}/nps-service/nps-service.service
echo "[Service] " >> ${HOME}/nps-service/nps-service.service
echo "WorkingDirectory=${HOME}/nps-service/" >> ${HOME}/nps-service/nps-service.service
echo "ExecStart=${HOME}/nps-service/nps" >> ${HOME}/nps-service/nps-service.service
echo "[Install] " >> ${HOME}/nps-service/nps-service.service
echo "WantedBy=multi-user.target" >> ${HOME}/nps-service/nps-service.service
chmod +x ${HOME}/nps-service/nps
cp ${HOME}/nps-service/nps-service.service /etc/systemd/system/

echo "enable nps service"
systemctl daemon-reload
systemctl enable nps-service.service
date=$(date +%s%N)
usage(){
    echo 'help message'
    echo '--bridge_ip 指定nps的ip或者host'
    echo '--bridge_port 指定nps的监听端口'
    echo '--vkey 指定nps后端配置客户端生成的key'
}
ARGS=`getopt \
    -o h \
    --long help, \
    --long bridge_ip:: \
    --long bridge_port:: \
    --long vkey:: \
    -n 'example.bash' -- "$@"`
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "${ARGS}"
while true ; do
    case "$1" in
        --bridge_ip)
            echo "specify bridge_ip as $2"; bridgeIP=$2; shift 2
            ;;
        --bridge_port)
            echo "specify bridge_port as $2"; bridgePort=$2; shift 2
            ;;
        --vkey)
            echo "specify vkey as $2"; vKey=$2; shift 2
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

cd ${HOME}
wget -c https://github.com/yisier/nps/releases/download/v0.27.01/freebsd_amd64_client.tar.gz -O NPSClient.tar.gz
mkdir -p nps-client
tar -xvf NPSClient.tar.gz -C nps-client
cd nps-client

echo "generate nps client"
echo "[Unit] " >> ${HOME}/nps-client/nps-client-${date}.service
echo "Description=NPS Client" >> ${HOME}/nps-client/nps-client-${date}.service
echo "After=network.target " >> ${HOME}/nps-client/nps-client-${date}.service
echo "[Service] " >> ${HOME}/nps-client/nps-client-${date}.service
echo "WorkingDirectory=${HOME}/nps-client/" >> ${HOME}/nps-client/nps-client-${date}.service
echo "ExecStart=${HOME}/nps-client/npc -server=${bridgeIP}:${bridgePort} -vkey=${vKey}" >> ${HOME}/nps-client/nps-client-${date}.service
echo "[Install] " >> ${HOME}/nps-client/nps-client-${date}.service
echo "WantedBy=multi-user.target" >> ${HOME}/nps-client/nps-client-${date}.service
chmod +x ${HOME}/nps-client/npc
cp ${HOME}/nps-client/nps-client-${date}.service /etc/systemd/system/nps-client.service

echo "enable nps service"
systemctl daemon-reload
systemctl enable nps-client.service
systemctl stop nps-client.service
systemctl start nps-client.service
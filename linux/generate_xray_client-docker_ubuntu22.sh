usage(){
    echo 'help message'
    echo '--domain 指定远程服务的域名'
    echo '--xray_server_port 指定xray服务的监听端口'
    echo '--local_socks_port 指定ss客户端的监听端口，使用网络时，往这个端口传数据'
    echo '--local_http_port 指定ss客户端的监听端口，使用网络时，往这个端口传数据'
    echo '--protocol 指定通信协议,默认vless'
    echo '--uuid 指定uuid'
    echo '--flow 指定flow类型，默认为xtls-rprx-vision'
    echo '--encryption 指定加密类型，默认为none'
    echo '--network 指定流量类型，默认为tcp'
    echo '--security 指定安全类型，默认为tls'
    echo '--version 指定xray版本，默认v1.8.9'
    echo '--do_offline 指定离线模型，即xray已经下载好了'
}
Protocol='vless'
Flow='xtls-rprx-vision'
Encryption='none'
Network='tcp'
Security='tls'
Version='v1.8.9'
ARGS=`getopt \
    -o h \
    --long help, \
    --long domain:: \
    --long xray_server_port:: \
    --long local_socks_port:: \
    --long local_http_port:: \
    --long protocol:: \
    --long uuid:: \
    --long flow:: \
    --long encryption:: \
    --long network:: \
    --long security:: \
    --long version:: \
    --long do_offline \
    -n 'example.bash' -- "$@"`
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "${ARGS}"
while true ; do
    case "$1" in
        --domain)
            echo "specify domain as $2"; Domain=$2; shift 2
            ;;
        --xray_server_port)
            echo "specify xray server port as $2"; xrayServerPort=$2; shift 2
            ;;
        --local_socks_port)
            echo "specify local socks port as $2"; localSocksPort=$2; shift 2
            ;;
        --local_http_port)
            echo "specify local http port as $2"; localHttpPort=$2; shift 2
            ;;
        --protocol)
            echo "specify protocol as $2"; Protocol=$2; shift 2
            ;;
        --uuid)
            echo "specify uuid as $2"; UUID=$2; shift 2
            ;;
        --flow)
            echo "specify flow as $2"; Flow=$2; shift 2
            ;;
        --encryption)
            echo "specify encryption as $2"; Encryption=$2; shift 2
            ;;
        --network)
            echo "specify network as $2"; Network=$2; shift 2
            ;;
        --security)
            echo "specify security as $2"; Security=$2; shift 2
            ;;
        --version)
            echo "specify version as $2"; Version=$2; shift 2
            ;;
        --do_offline)
            echo "specify offline"; Offline=1; shift 1
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
exec_dir=$(pwd)
# 下载工具
if test "${Offline}"; then
    echo "do offline"
else
    wget https://github.com/XTLS/Xray-core/releases/download/${Version}/Xray-linux-64.zip -O Xray${Version}.zip
fi
xray_dir=${exec_dir}/Xray-${Version}
mkdir -p ${xray_dir}
cd Xray-${Version}/
unzip -a ../Xray${Version}.zip
cd ${exec_dir}
# 生成配置
conf_dir=${xray_dir}
conf_path=${conf_dir}/conf.json
touch ${conf_path}
rm ${conf_path}
echo "// REFERENCE:" >> ${conf_path}
echo "// https://github.com/XTLS/Xray-examples" >> ${conf_path}
echo "// https://xtls.github.io/config/" >> ${conf_path}
echo "" >> ${conf_path}
echo "// 常用的config文件，不论服务器端还是客户端，都有5个部分。外加小小白解读：" >> ${conf_path}
echo "// ┌─ 1_log          日志设置 - 日志写什么，写哪里（出错时有据可查）" >> ${conf_path}
echo "// ├─ 2_dns          DNS-设置 - DNS怎么查（防DNS污染、防偷窥、避免国内外站匹配到国外服务器等）" >> ${conf_path}
echo "// ├─ 3_routing      分流设置 - 流量怎么分类处理（是否过滤广告、是否国内外分流）" >> ${conf_path}
echo "// ├─ 4_inbounds     入站设置 - 什么流量可以流入Xray" >> ${conf_path}
echo "// └─ 5_outbounds    出站设置 - 流出Xray的流量往哪里去" >> ${conf_path}
echo "" >> ${conf_path}
echo "{" >> ${conf_path}
echo "  // 1_日志设置" >> ${conf_path}
echo "  // 注意，本例中我默认注释掉了日志文件，因为windows, macOS, Linux 需要写不同的路径，请自行配置" >> ${conf_path}
echo "  \"log\": {" >> ${conf_path}
echo "    \"access\": \"${xray_dir}/access.log\",    // 访问记录" >> ${conf_path}
echo "    \"error\": \"${xray_dir}/error.log\",    // 错误记录" >> ${conf_path}
echo "    \"loglevel\": \"info\" // 内容从少到多: \"none\", \"error\", \"warning\", \"info\", \"debug\"" >> ${conf_path}
echo "  }," >> ${conf_path}
echo "" >> ${conf_path}
echo "  // 2_DNS设置" >> ${conf_path}
echo "  \"dns\": {" >> ${conf_path}
echo "    \"servers\": [" >> ${conf_path}
echo "      // 2.1 国外域名使用国外DNS查询" >> ${conf_path}
echo "      {" >> ${conf_path}
echo "        \"address\": \"1.1.1.1\"," >> ${conf_path}
echo "        \"domains\": [\"geosite:geolocation-!cn\"]" >> ${conf_path}
echo "      }," >> ${conf_path}
echo "      // 2.2 国内域名使用国内DNS查询，并期待返回国内的IP，若不是国内IP则舍弃，用下一个查询" >> ${conf_path}
echo "      {" >> ${conf_path}
echo "        \"address\": \"223.5.5.5\"," >> ${conf_path}
echo "        \"domains\": [\"geosite:cn\"]," >> ${conf_path}
echo "        \"expectIPs\": [\"geoip:cn\"]" >> ${conf_path}
echo "      }," >> ${conf_path}
echo "      // 2.3 作为2.2的备份，对国内网站进行二次查询" >> ${conf_path}
echo "      {" >> ${conf_path}
echo "        \"address\": \"114.114.114.114\"," >> ${conf_path}
echo "        \"domains\": [\"geosite:cn\"]" >> ${conf_path}
echo "      }," >> ${conf_path}
echo "      // 2.4 最后的备份，上面全部失败时，用本机DNS查询" >> ${conf_path}
echo "      \"localhost\"" >> ${conf_path}
echo "    ]" >> ${conf_path}
echo "  }," >> ${conf_path}
echo "" >> ${conf_path}
echo "  // 3_分流设置" >> ${conf_path}
echo "  // 所谓分流，就是将符合否个条件的流量，用指定tag的出站协议去处理（对应配置的5.x内容）" >> ${conf_path}
echo "  \"routing\": {" >> ${conf_path}
echo "    \"domainStrategy\": \"IPIfNonMatch\"," >> ${conf_path}
echo "    \"rules\": [" >> ${conf_path}
echo "      // 3.1 广告域名屏蔽" >> ${conf_path}
echo "      {" >> ${conf_path}
echo "        \"type\": \"field\"," >> ${conf_path}
echo "        \"domain\": [\"geosite:category-ads-all\"]," >> ${conf_path}
echo "        \"outboundTag\": \"block\"" >> ${conf_path}
echo "      }," >> ${conf_path}
echo "      // 3.2 国内域名直连" >> ${conf_path}
echo "      {" >> ${conf_path}
echo "        \"type\": \"field\"," >> ${conf_path}
echo "        \"domain\": [\"geosite:cn\"]," >> ${conf_path}
echo "        \"outboundTag\": \"direct\"" >> ${conf_path}
echo "      }," >> ${conf_path}
echo "      // 3.3 国内IP直连" >> ${conf_path}
echo "      {" >> ${conf_path}
echo "        \"type\": \"field\"," >> ${conf_path}
echo "        \"ip\": [\"geoip:cn\", \"geoip:private\"]," >> ${conf_path}
echo "        \"outboundTag\": \"direct\"" >> ${conf_path}
echo "      }," >> ${conf_path}
echo "      // 3.4 国外域名代理" >> ${conf_path}
echo "      {" >> ${conf_path}
echo "        \"type\": \"field\"," >> ${conf_path}
echo "        \"domain\": [\"geosite:geolocation-!cn\"]," >> ${conf_path}
echo "        \"outboundTag\": \"proxy\"" >> ${conf_path}
echo "      }," >> ${conf_path}
echo "      // 3.5 默认规则" >> ${conf_path}
echo "      // 在Xray中，任何不符合上述路由规则的流量，都会默认使用【第一个outbound（5.1）】的设置，所以一定要把转发VPS的outbound放第一个" >> ${conf_path}
echo "      // 3.6 走国内\"223.5.5.5\"的DNS查询流量分流走direct出站" >> ${conf_path}
echo "      {" >> ${conf_path}
echo "        \"type\": \"field\"," >> ${conf_path}
echo "        \"ip\": [\"223.5.5.5\"]," >> ${conf_path}
echo "        \"outboundTag\": \"direct\"" >> ${conf_path}
echo "      }" >> ${conf_path}
echo "    ]" >> ${conf_path}
echo "  }," >> ${conf_path}
echo "" >> ${conf_path}
echo "  // 4_入站设置" >> ${conf_path}
echo "  \"inbounds\": [" >> ${conf_path}
echo "    // 4.1 一般都默认使用socks5协议作本地转发" >> ${conf_path}
echo "    {" >> ${conf_path}
echo "      \"tag\": \"socks-in\"," >> ${conf_path}
echo "      \"protocol\": \"socks\"," >> ${conf_path}
echo "      \"listen\": \"0.0.0.0\", // 这个是通过socks5协议做本地转发的地址" >> ${conf_path}
echo "      \"port\": ${localSocksPort}, // 这个是通过socks5协议做本地转发的端口" >> ${conf_path}
echo "      \"settings\": {" >> ${conf_path}
echo "        \"udp\": true" >> ${conf_path}
echo "      }" >> ${conf_path}
echo "    }," >> ${conf_path}
echo "    // 4.2 有少数APP不兼容socks协议，需要用http协议做转发，则可以用下面的端口" >> ${conf_path}
echo "    {" >> ${conf_path}
echo "      \"tag\": \"http-in\"," >> ${conf_path}
echo "      \"protocol\": \"http\"," >> ${conf_path}
echo "      \"listen\": \"0.0.0.0\", // 这个是通过http协议做本地转发的地址" >> ${conf_path}
echo "      \"port\": ${localHttpPort} // 这个是通过http协议做本地转发的端口" >> ${conf_path}
echo "    }" >> ${conf_path}
echo "  ]," >> ${conf_path}
echo "" >> ${conf_path}
echo "  // 5_出站设置" >> ${conf_path}
echo "  \"outbounds\": [" >> ${conf_path}
echo "    // 5.1 默认转发VPS" >> ${conf_path}
echo "    // 一定放在第一个，在routing 3.5 里面已经说明了，这等于是默认规则，所有不符合任何规则的流量都走这个" >> ${conf_path}
echo "    {" >> ${conf_path}
echo "      \"tag\": \"proxy\"," >> ${conf_path}
echo "      \"protocol\": \"${Protocol}\"," >> ${conf_path}
echo "      \"settings\": {" >> ${conf_path}
echo "        \"vnext\": [" >> ${conf_path}
echo "          {" >> ${conf_path}
echo "            \"address\": \"${Domain}\", // 替换成你的真实域名" >> ${conf_path}
echo "            \"port\": ${xrayServerPort}," >> ${conf_path}
echo "            \"users\": [" >> ${conf_path}
echo "              {" >> ${conf_path}
echo "                \"id\": \"${UUID}\", // 和服务器端的一致" >> ${conf_path}
echo "                \"flow\": \"${Flow}\"," >> ${conf_path}
echo "                \"encryption\": \"${Encryption}\"," >> ${conf_path}
echo "                \"level\": 0" >> ${conf_path}
echo "              }" >> ${conf_path}
echo "            ]" >> ${conf_path}
echo "          }" >> ${conf_path}
echo "        ]" >> ${conf_path}
echo "      }," >> ${conf_path}
echo "      \"streamSettings\": {" >> ${conf_path}
echo "        \"network\": \"${Network}\"," >> ${conf_path}
echo "        \"security\": \"${Security}\"," >> ${conf_path}
echo "        \"tlsSettings\": {" >> ${conf_path}
echo "          \"serverName\": \"${Domain}\", // 替换成你的真实域名" >> ${conf_path}
echo "          \"allowInsecure\": true, // 禁止不安全证书" >> ${conf_path}
echo "          \"fingerprint\": \"chrome\" // 通过 uTLS 库 模拟 Chrome / Firefox / Safari 或随机生成的指纹" >> ${conf_path}
echo "        }" >> ${conf_path}
echo "      }" >> ${conf_path}
echo "    }," >> ${conf_path}
echo "    // 5.2 用freedom协议直连出站，即当routing中指定'direct'流出时，调用这个协议做处理" >> ${conf_path}
echo "    {" >> ${conf_path}
echo "      \"tag\": \"direct\"," >> ${conf_path}
echo "      \"protocol\": \"freedom\"" >> ${conf_path}
echo "    }," >> ${conf_path}
echo "    // 5.3 用blackhole协议屏蔽流量，即当routing中指定'block'时，调用这个协议做处理" >> ${conf_path}
echo "    {" >> ${conf_path}
echo "      \"tag\": \"block\"," >> ${conf_path}
echo "      \"protocol\": \"blackhole\"" >> ${conf_path}
echo "    }" >> ${conf_path}
echo "  ]" >> ${conf_path}
echo "}" >> ${conf_path}

echo "${xray_dir}/xray -c ${conf_path}" > ${xray_dir}/start.sh

docker pull payforsins/xray:latest
# todo: 这里需要增加判断
#docker network create CI
# todo: 这里也需要增加判断
docker run -it --ipc host --network CI --network-alias xray --name xray -v ${xray_dir}:${xray_dir} -t payforsins/xray:latest /bin/bash -c "bash ${xray_dir}/start.sh"
#docker run -it --ipc host --network CI --network-alias xray --name xray -v ${xray_dir}:${xray_dir} -t payforsins/xray:latest /bin/bash
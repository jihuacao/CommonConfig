usage(){
    echo 'help message'
    echo '--domain 指定远程服务的域名'
    echo '--xray_server_port 指定xray服务的监听端口'
    echo '--uuid 指定uuid'
    echo '--do_offline 指定离线模型，即xray已经下载好了'
    echo '--protocol 指定通信协议,默认vless'
    echo '--flow 指定flow类型，默认为xtls-rprx-vision'
    echo '--encryption 指定加密类型，默认为none'
    echo '--network 指定流量类型，默认为tcp'
    echo '--security 指定安全类型，默认为tls'
    echo '--version 指定xray版本，默认v1.8.9'
    echo '--site_http_port 指定网站端口，默认为80'
    echo '--site_https_port 指定网站端口，默认为443'
}
siteHttpPort=80
siteHttpsPort=443
Protocol='vless'
Flow='xtls-rprx-vision'
Encryption='none'
Network='tcp'
Security='tls'
Version='v1.8.9'
ARGS=`getopt \
    -o h \
    --long help, \
    --long site_http_port:: \
    --long site_https_port:: \
    --long domain:: \
    --long xray_server_port:: \
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
        --site_http_port)
            echo "specify site http port as $2"; siteHttpPort=$2; shift 2
            ;;
        --site_https_port)
            echo "specify site https port as $2"; siteHttpsPort=$2; shift 2
            ;;
        --domain)
            echo "specify domain as $2"; Domain=$2; shift 2
            ;;
        --xray_server_port)
            echo "specify xray server port as $2"; xrayServerPort=$2; shift 2
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

# 配置服务端
## 构建一个简单的网站来充当门面防止查水表
sudo apt update
apt -y install nginx
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
### 处理防火墙策略
ufw status
ufw allow 'Nginx Full'
ufw status
#### 生成简单页面
#simple_site=/var/www/html/
#mkdir -p ${simple_site}
#rm -f ${simple_site}/index.html
#echo "<html lang=\"\">" > ${simple_site}/index.html
#echo "  <!-- Text between angle brackets is an HTML tag and is not displayed." >> ${simple_site}/index.html
#echo "        Most tags, such as the HTML and /HTML tags that surround the contents of" >> ${simple_site}/index.html
#echo "        a page, come in pairs; some tags, like HR, for a horizontal rule, stand" >> ${simple_site}/index.html
#echo "        alone. Comments, such as the text you're reading, are not displayed when" >> ${simple_site}/index.html
#echo "        the Web page is shown. The information between the HEAD and /HEAD tags is" >> ${simple_site}/index.html
#echo "        not displayed. The information between the BODY and /BODY tags is displayed.-->" >> ${simple_site}/index.html
#echo "  <head>" >> ${simple_site}/index.html
#echo "    <title>Enter a title, displayed at the top of the window.</title>" >> ${simple_site}/index.html
#echo "  </head>" >> ${simple_site}/index.html
#echo "  <!-- The information between the BODY and /BODY tags is displayed.-->" >> ${simple_site}/index.html
#echo "  <body>" >> ${simple_site}/index.html
#echo "    <h1>Enter the main heading, usually the same as the title.</h1>" >> ${simple_site}/index.html
#echo "    <p>Be <b>bold</b> in stating your key points. Put them in a list:</p>" >> ${simple_site}/index.html
#echo "    <ul>" >> ${simple_site}/index.html
#echo "      <li>The first item in your list</li>" >> ${simple_site}/index.html
#echo "      <li>The second item; <i>italicize</i> key words</li>" >> ${simple_site}/index.html
#echo "    </ul>" >> ${simple_site}/index.html
#echo "    <p>Improve your image by including an image.</p>" >> ${simple_site}/index.html
#echo "    <p>" >> ${simple_site}/index.html
#echo "      <img src=\"https://i.imgur.com/SEBww.jpg\" alt=\"A Great HTML Resource\" />" >> ${simple_site}/index.html
#echo "    </p>" >> ${simple_site}/index.html
#echo "    <p>" >> ${simple_site}/index.html
#echo "      Add a link to your favorite" >> ${simple_site}/index.html
#echo "      <a href=\"https://www.dummies.com/\">Web site</a>. Break up your page" >> ${simple_site}/index.html
#echo "      with a horizontal rule or two." >> ${simple_site}/index.html
#echo "    </p>" >> ${simple_site}/index.html
#echo "    <hr />" >> ${simple_site}/index.html
#echo "    <p>" >> ${simple_site}/index.html
#echo "      Finally, link to <a href=\"page2.html\">another page</a> in your own Web" >> ${simple_site}/index.html
#echo "      site." >> ${simple_site}/index.html
#echo "    </p>" >> ${simple_site}/index.html
#echo "    <!-- And add a copyright notice.-->" >> ${simple_site}/index.html
#echo "    <p>&#169; Wiley Publishing, 2011</p>" >> ${simple_site}/index.html
#echo "  </body>" >> ${simple_site}/index.html
#echo "</html>" >> ${simple_site}/index.html
#### 处理nginx代理
#mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
#echo "user www-data;" >> /etc/nginx/nginx.conf
#echo "worker_processes auto;" >> /etc/nginx/nginx.conf
#echo "pid /run/nginx.pid;" >> /etc/nginx/nginx.conf
#echo "include /etc/nginx/modules-enabled/*.conf;" >> /etc/nginx/nginx.conf
#echo "events {" >> /etc/nginx/nginx.conf
#echo "    worker_connections 768;" >> /etc/nginx/nginx.conf
#echo "}" >> /etc/nginx/nginx.conf
#echo "http {" >> /etc/nginx/nginx.conf
#echo "        server {" >> /etc/nginx/nginx.conf
#echo "                listen 80;" >> /etc/nginx/nginx.conf
#echo "                server_name ${Domain};" >> /etc/nginx/nginx.conf
#echo "                root /root/www/webpage;" >> /etc/nginx/nginx.conf
#echo "                index index.html;" >> /etc/nginx/nginx.conf
#echo "        }" >> /etc/nginx/nginx.conf
#echo "    sendfile on;" >> /etc/nginx/nginx.conf
#echo "    tcp_nopush on;" >> /etc/nginx/nginx.conf
#echo "    types_hash_max_size 2048;" >> /etc/nginx/nginx.conf
#echo "    include /etc/nginx/mime.types;" >> /etc/nginx/nginx.conf
#echo "    default_type application/octet-stream;" >> /etc/nginx/nginx.conf
#echo "    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE" >> /etc/nginx/nginx.conf
#echo "    ssl_prefer_server_ciphers on;" >> /etc/nginx/nginx.conf
#echo "    access_log /var/log/nginx/access.log;" >> /etc/nginx/nginx.conf
#echo "    error_log /var/log/nginx/error.log;" >> /etc/nginx/nginx.conf
#echo "    gzip on;" >> /etc/nginx/nginx.conf
#echo "    include /etc/nginx/conf.d/*.conf;" >> /etc/nginx/nginx.conf
#echo "    include /etc/nginx/sites-enabled/*;" >> /etc/nginx/nginx.conf
#echo "}" >> /etc/nginx/nginx.conf
### 重启nginx
systemctl reload nginx
## 生成证书
cert_dir=${exec_dir}/Cert
mkdir -p ${cert_dir}
### 定义 acme.sh 安装路径
ACME_DIR=/root/.acme.sh/
### 确保 acme.sh 安装在 ACME_DIR 路径下
if [ ! -d "$ACME_DIR" ]; then
    mkdir -p "$ACME_DIR"
    wget -qO- "https://get.acme.sh" | sh
fi
### 导入 acme.sh 环境变量
source "$ACME_DIR/acme.sh.env"
${ACME_DIR}/acme.sh --upgrade --auto-upgrade
### 测试域名
${ACME_DIR}/acme.sh --issue --server letsencrypt --test -d ${Domain} -w /var/www/html --keylength ec-256
${ACME_DIR}/acme.sh --set-default-ca --server letsencrypt
### 正式申请
${ACME_DIR}/acme.sh --issue -d ${Domain} -w /var/www/html --keylength ec-256 --force
### 安装证书
${ACME_DIR}/acme.sh --installcert -d ${Domain} --cert-file ${cert_dir}/cert.crt --key-file ${cert_dir}/cert.key --fullchain-file ${cert_dir}/fullchain.crt --ecc
## 下载工具
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
## 生成配置文件
### 配置文件目录
conf_dir=${xray_dir}
### 日志目录
xray_log_dir=${xray_dir}
#mkdir -p ${xray_log_dir}
#touch ${xray_log_dir}/access.log
#touch ${xray_log_dir}/error.log
#chmod a+w ${xray_log_dir}/*.log
### 配置文件
conf_path=${conf_dir}/conf.json
touch ${conf_path}
rm ${conf_path}
echo "// REFERENCE:" >> ${conf_path}
echo "// https://github.com/XTLS/Xray-examples" >> ${conf_path}
echo "// https://xtls.github.io/config/" >> ${conf_path}
echo "// 常用的 config 文件，不论服务器端还是客户端，都有 5 个部分。外加小小白解读：" >> ${conf_path}
echo "// ┌─ 1*log 日志设置 - 日志写什么，写哪里（出错时有据可查）" >> ${conf_path}
echo "// ├─ 2_dns DNS-设置 - DNS 怎么查（防 DNS 污染、防偷窥、避免国内外站匹配到国外服务器等）" >> ${conf_path}
echo "// ├─ 3_routing 分流设置 - 流量怎么分类处理（是否过滤广告、是否国内外分流）" >> ${conf_path}
echo "// ├─ 4_inbounds 入站设置 - 什么流量可以流入 Xray" >> ${conf_path}
echo "// └─ 5_outbounds 出站设置 - 流出 Xray 的流量往哪里去" >> ${conf_path}
echo "{" >> ${conf_path}
echo "  // 1\_日志设置" >> ${conf_path}
echo "  \"log\": {" >> ${conf_path}
echo "    \"loglevel\": \"warning\", // 内容从少到多: \"none\", \"error\", \"warning\", \"info\", \"debug\"" >> ${conf_path}
echo "    \"access\": \"${xray_log_dir}/access.log\", // 访问记录" >> ${conf_path}
echo "    \"error\": \"${xray_log_dir}/error.log\" // 错误记录" >> ${conf_path}
echo "  }," >> ${conf_path}
echo "  // 2_DNS 设置" >> ${conf_path}
echo "  \"dns\": {" >> ${conf_path}
echo "    \"servers\": [" >> ${conf_path}
echo "      \"https+local://1.1.1.1/dns-query\", // 首选 1.1.1.1 的 DoH 查询，牺牲速度但可防止 ISP 偷窥" >> ${conf_path}
echo "      \"localhost\"" >> ${conf_path}
echo "    ]" >> ${conf_path}
echo "  }," >> ${conf_path}
echo "  // 3*分流设置" >> ${conf_path}
echo "  \"routing\": {" >> ${conf_path}
echo "    \"domainStrategy\": \"IPIfNonMatch\"," >> ${conf_path}
echo "    \"rules\": [" >> ${conf_path}
echo "      // 3.1 防止服务器本地流转问题：如内网被攻击或滥用、错误的本地回环等" >> ${conf_path}
echo "      {" >> ${conf_path}
echo "        \"type\": \"field\"," >> ${conf_path}
echo "        \"ip\": [" >> ${conf_path}
echo "          \"geoip:private\" // 分流条件：geoip 文件内，名为\"private\"的规则（本地）" >> ${conf_path}
echo "        ]," >> ${conf_path}
echo "        \"outboundTag\": \"block\" // 分流策略：交给出站\"block\"处理（黑洞屏蔽）" >> ${conf_path}
echo "      }," >> ${conf_path}
echo "      {" >> ${conf_path}
echo "        // 3.2 防止服务器直连国内" >> ${conf_path}
echo "        \"type\": \"field\"," >> ${conf_path}
echo "        \"ip\": [\"geoip:cn\"]," >> ${conf_path}
echo "        \"outboundTag\": \"block\"" >> ${conf_path}
echo "      }," >> ${conf_path}
echo "      // 3.3 屏蔽广告" >> ${conf_path}
echo "      {" >> ${conf_path}
echo "        \"type\": \"field\"," >> ${conf_path}
echo "        \"domain\": [" >> ${conf_path}
echo "          \"geosite:category-ads-all\" // 分流条件：geosite 文件内，名为\"category-ads-all\"的规则（各种广告域名）" >> ${conf_path}
echo "        ]," >> ${conf_path}
echo "        \"outboundTag\": \"block\" // 分流策略：交给出站\"block\"处理（黑洞屏蔽）" >> ${conf_path}
echo "      }" >> ${conf_path}
echo "    ]" >> ${conf_path}
echo "  }," >> ${conf_path}
echo "  // 4*入站设置" >> ${conf_path}
echo "  // 4.1 这里只写了一个最简单的 vless+xtls 的入站，因为这是 Xray 最强大的模式。如有其他需要，请根据模版自行添加。" >> ${conf_path}
echo "  \"inbounds\": [" >> ${conf_path}
echo "    {" >> ${conf_path}
echo "      \"port\": ${xrayServerPort}," >> ${conf_path}
echo "      \"protocol\": \"${Protocol}\"," >> ${conf_path}
echo "      \"settings\": {" >> ${conf_path}
echo "        \"clients\": [" >> ${conf_path}
echo "          {" >> ${conf_path}
echo "            \"id\": \"${UUID}\", // 填写你的 UUID" >> ${conf_path}
echo "            \"flow\": \"${Flow}\"," >> ${conf_path}
echo "            \"level\": 0," >> ${conf_path}
echo "            \"email\": \"root@${Domain}\"" >> ${conf_path}
echo "          }" >> ${conf_path}
echo "        ]," >> ${conf_path}
echo "        \"decryption\": \"none\"," >> ${conf_path}
echo "        \"fallbacks\": [" >> ${conf_path}
echo "          {" >> ${conf_path}
echo "            \"dest\": ${siteHttpPort}// 默认回落到防探测的代理" >> ${conf_path}
echo "          }" >> ${conf_path}
echo "        ]" >> ${conf_path}
echo "      }," >> ${conf_path}
echo "      \"streamSettings\": {" >> ${conf_path}
echo "        \"network\": \"${Network}\"," >> ${conf_path}
echo "        \"security\": \"${Security}\"," >> ${conf_path}
echo "        \"tlsSettings\": {" >> ${conf_path}
echo "          \"alpn\": \"http/1.1\"," >> ${conf_path}
echo "          \"certificates\": [" >> ${conf_path}
echo "            {" >> ${conf_path}
echo "              \"certificateFile\": \"${cert_dir}/cert.crt\"," >> ${conf_path}
echo "              \"keyFile\": \"${cert_dir}/cert.key\"" >> ${conf_path}
echo "            }" >> ${conf_path}
echo "          ]" >> ${conf_path}
echo "        }" >> ${conf_path}
echo "      }" >> ${conf_path}
echo "    }" >> ${conf_path}
echo "  ]," >> ${conf_path}
echo "  // 5*出站设置" >> ${conf_path}
echo "  \"outbounds\": [" >> ${conf_path}
echo "    // 5.1 第一个出站是默认规则，freedom 就是对外直连（vps 已经是外网，所以直连）" >> ${conf_path}
echo "    {" >> ${conf_path}
echo "      \"tag\": \"direct\"," >> ${conf_path}
echo "      \"protocol\": \"freedom\"" >> ${conf_path}
echo "    }," >> ${conf_path}
echo "    // 5.2 屏蔽规则，blackhole 协议就是把流量导入到黑洞里（屏蔽）" >> ${conf_path}
echo "    {" >> ${conf_path}
echo "      \"tag\": \"block\"," >> ${conf_path}
echo "      \"protocol\": \"blackhole\"" >> ${conf_path}
echo "    }" >> ${conf_path}
echo "  ]" >> ${conf_path}
echo "}" >> ${conf_path}
## 构建服务
service_path=${xray_dir}/xray-service.service
touch ${service_path}
rm ${service_path}
echo "[Unit]" >> ${service_path}
echo "Description=xray Server ${Version} ${Domain}:${xrayServerPort}" >> ${service_path}
echo "After=network.target " >> ${service_path}
echo "[Service] " >> ${service_path}
echo "ExecStart=${xray_dir}/xray -c ${conf_path}" >> ${service_path}
echo "[Install] " >> ${service_path}
echo "WantedBy=multi-user.target" >> ${service_path}
cp ${service_path} /etc/systemd/system/
#now=$(pwd) && cd linux/kcptun && python config.py --config_server --server_executable_dir=/root/kcptun --server_config_path=${HOME}/kcptun-service --server_service_dir=/root/kcptun --server_target_port ${ssPort} --server_listen_port ${kcptunPort} --server_target_ip=${IP} && cd ${now}
systemctl daemon-reload
systemctl start xray-service
systemctl status xray-service
systemctl enable xray-service
## 使用BBR
## 防火墙端口打开
iptables -I INPUT -p tcp --dport ${xrayServerPort} -j ACCEPT
## 保存防火墙策略
iptables-save
apt -y install iptables-persistent
service netfilter-persistent save

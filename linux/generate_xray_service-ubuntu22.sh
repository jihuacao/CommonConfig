# 使用Xray，Xray系列使用伪装网站来防止主动探测，因此需要建立一个简单网站、需要证书
usage(){
    echo 'help message'
    echo '--domain 指定域名'
    echo '--xray_port 指定xray代理服务的监听端口'
    echo '--proxy_port_start 指定端口转发结尾端口，proxy_port_start:proxy_port_end-->(将会被映射到)xray_port'
    echo '--proxy_port_end 指定端口转发结尾端口，proxy_port_start:proxy_port_end-->(将会被映射到)xray_port'
    echo '--uuid 指定密码'
    echo '--protocol 指定协议'
    echo '--flow 指定flow'
    echo '--encrypt_method 指定加密方式'
}
ARGS=`getopt \
    -o h\
    --long help, \
    --long domain:: \
    --long xray_port:: \
    --long proxy_port_start:: \
    --long proxy_port_end:: \
    --long uuid:: \
    --long protocol:: \
    --long encrypt_method:: \
    -n 'example.bash' -- "$@"`
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "${ARGS}"
while true ; do
    case "$1" in
        --domain)
            echo "specify domain as $2"; IP=$2; shift 2
            ;;
        --xray_port)
            echo "specify xray_port as $2"; ssPort=$2; shift 2
            ;;
        --proxy_port_start)
            echo "specify proxy_port_start as $2"; proxyPorts=$2; shift 2
            ;;
        --proxy_port_end)
            echo "specify proxy_port_end as $2"; proxyPorte=$2; shift 2
            ;;
        --uuid)
            echo "add uuid $2"; password=$2; shift 2
            ;;
        --protocol)
            echo "specify protocol as $2"; password=$2; shift 2
            ;;
        --encrypt_method)
            echo "specify encrypt method as $2"; encryptMethod=$2; shift 2
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

# https://xtls.github.io/document/level-0/ch07-xray-server.html#_7-2-%E5%AE%89%E8%A3%85-xray
Version=v1.8.9
# 下载Xray
wget https://github.com/XTLS/Xray-core/releases/download/${Version}/Xray-linux-64.zip -O Xray${Version}.zip
mkdir -p Xray-${Version}
cd Xray-${Version}/
unzip ../Xray${Version}.zip
cd ..
# 配置服务端
## 构建一个简单的网站来充当门面防止查水表
sudo apt update
apt -y install nginx
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
### 处理防火墙策略
ufw status
ufw allow 'Nginx Full'
ufw status
### 生成简单页面
mkdir -p ~/www/webpage/
rm -f ~/www/webpage/index.html
echo "<html lang="">" >> ~/www/webpage/index.html
echo "  <!-- Text between angle brackets is an HTML tag and is not displayed." >> ~/www/webpage/index.html
echo "        Most tags, such as the HTML and /HTML tags that surround the contents of" >> ~/www/webpage/index.html
echo "        a page, come in pairs; some tags, like HR, for a horizontal rule, stand" >> ~/www/webpage/index.html
echo "        alone. Comments, such as the text you're reading, are not displayed when" >> ~/www/webpage/index.html
echo "        the Web page is shown. The information between the HEAD and /HEAD tags is" >> ~/www/webpage/index.html
echo "        not displayed. The information between the BODY and /BODY tags is displayed.-->" >> ~/www/webpage/index.html
echo "  <head>" >> ~/www/webpage/index.html
echo "    <title>Enter a title, displayed at the top of the window.</title>" >> ~/www/webpage/index.html
echo "  </head>" >> ~/www/webpage/index.html
echo "  <!-- The information between the BODY and /BODY tags is displayed.-->" >> ~/www/webpage/index.html
echo "  <body>" >> ~/www/webpage/index.html
echo "    <h1>Enter the main heading, usually the same as the title.</h1>" >> ~/www/webpage/index.html
echo "    <p>Be <b>bold</b> in stating your key points. Put them in a list:</p>" >> ~/www/webpage/index.html
echo "    <ul>" >> ~/www/webpage/index.html
echo "      <li>The first item in your list</li>" >> ~/www/webpage/index.html
echo "      <li>The second item; <i>italicize</i> key words</li>" >> ~/www/webpage/index.html
echo "    </ul>" >> ~/www/webpage/index.html
echo "    <p>Improve your image by including an image.</p>" >> ~/www/webpage/index.html
echo "    <p>" >> ~/www/webpage/index.html
echo "      <img src="https://i.imgur.com/SEBww.jpg" alt="A Great HTML Resource" />" >> ~/www/webpage/index.html
echo "    </p>" >> ~/www/webpage/index.html
echo "    <p>" >> ~/www/webpage/index.html
echo "      Add a link to your favorite" >> ~/www/webpage/index.html
echo "      <a href="https://www.dummies.com/">Web site</a>. Break up your page" >> ~/www/webpage/index.html
echo "      with a horizontal rule or two." >> ~/www/webpage/index.html
echo "    </p>" >> ~/www/webpage/index.html
echo "    <hr />" >> ~/www/webpage/index.html
echo "    <p>" >> ~/www/webpage/index.html
echo "      Finally, link to <a href="page2.html">another page</a> in your own Web" >> ~/www/webpage/index.html
echo "      site." >> ~/www/webpage/index.html
echo "    </p>" >> ~/www/webpage/index.html
echo "    <!-- And add a copyright notice.-->" >> ~/www/webpage/index.html
echo "    <p>&#169; Wiley Publishing, 2011</p>" >> ~/www/webpage/index.html
echo "  </body>" >> ~/www/webpage/index.html
echo "</html>" >> ~/www/webpage/index.html
### 处理nginx代理
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
echo "user www-data;" >> /etc/nginx/nginx.conf
echo "worker_processes auto;" >> /etc/nginx/nginx.conf
echo "pid /run/nginx.pid;" >> /etc/nginx/nginx.conf
echo "include /etc/nginx/modules-enabled/*.conf;" >> /etc/nginx/nginx.conf
echo "events {" >> /etc/nginx/nginx.conf
echo "    worker_connections 768;" >> /etc/nginx/nginx.conf
echo "}" >> /etc/nginx/nginx.conf
echo "http {" >> /etc/nginx/nginx.conf
echo "        server {" >> /etc/nginx/nginx.conf
echo "                listen 80;" >> /etc/nginx/nginx.conf
echo "                server_name ${domain};" >> /etc/nginx/nginx.conf
echo "                root /root/www/webpage;" >> /etc/nginx/nginx.conf
echo "                index index.html;" >> /etc/nginx/nginx.conf
echo "        }" >> /etc/nginx/nginx.conf
echo "    sendfile on;" >> /etc/nginx/nginx.conf
echo "    tcp_nopush on;" >> /etc/nginx/nginx.conf
echo "    types_hash_max_size 2048;" >> /etc/nginx/nginx.conf
echo "    include /etc/nginx/mime.types;" >> /etc/nginx/nginx.conf
echo "    default_type application/octet-stream;" >> /etc/nginx/nginx.conf
echo "    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE" >> /etc/nginx/nginx.conf
echo "    ssl_prefer_server_ciphers on;" >> /etc/nginx/nginx.conf
echo "    access_log /var/log/nginx/access.log;" >> /etc/nginx/nginx.conf
echo "    error_log /var/log/nginx/error.log;" >> /etc/nginx/nginx.conf
echo "    gzip on;" >> /etc/nginx/nginx.conf
echo "    include /etc/nginx/conf.d/*.conf;" >> /etc/nginx/nginx.conf
echo "    include /etc/nginx/sites-enabled/*;" >> /etc/nginx/nginx.conf
echo "}" >> /etc/nginx/nginx.conf
### 重启nginx
systemctl reload nginx
## 生成证书
wget -O -  https://get.acme.sh | sh
. .bashrc
acme.sh --upgrade --auto-upgrade
### 测试域名
acme.sh --issue --server letsencrypt --test -d ${domain} -w /root/www/webpage --keylength ec-256
acme.sh --set-default-ca --server letsencrypt
### 正式申请
acme.sh --issue -d ${domain} -w /root/www/webpage --keylength ec-256 --force
### 安装证书
acme.sh --installcert -d ${domain} --cert-file ./Xray-${Version}/cert.crt --key-file ./Xray-${Version}/cert.key --fullchain-file ./Xray-${Versoin}/fullchain.crt --ecc
## 生成配置文件
touch ./Xray-${Version}/conf.json
rm ./Xray-${Version}/conf.json
echo "// REFERENCE:" >> ./Xray-${Version}/conf.json
echo "// https://github.com/XTLS/Xray-examples" >> ./Xray-${Version}/conf.json
echo "// https://xtls.github.io/config/" >> ./Xray-${Version}/conf.json
echo "// 常用的 config 文件，不论服务器端还是客户端，都有 5 个部分。外加小小白解读：" >> ./Xray-${Version}/conf.json
echo "// ┌─ 1*log 日志设置 - 日志写什么，写哪里（出错时有据可查）" >> ./Xray-${Version}/conf.json
echo "// ├─ 2_dns DNS-设置 - DNS 怎么查（防 DNS 污染、防偷窥、避免国内外站匹配到国外服务器等）" >> ./Xray-${Version}/conf.json
echo "// ├─ 3_routing 分流设置 - 流量怎么分类处理（是否过滤广告、是否国内外分流）" >> ./Xray-${Version}/conf.json
echo "// ├─ 4_inbounds 入站设置 - 什么流量可以流入 Xray" >> ./Xray-${Version}/conf.json
echo "// └─ 5_outbounds 出站设置 - 流出 Xray 的流量往哪里去" >> ./Xray-${Version}/conf.json
echo "{" >> ./Xray-${Version}/conf.json
echo "  // 1\_日志设置" >> ./Xray-${Version}/conf.json
echo "  \"log\": {" >> ./Xray-${Version}/conf.json
echo "    \"loglevel\": \"warning\", // 内容从少到多: \"none\", \"error\", \"warning\", \"info\", \"debug\"" >> ./Xray-${Version}/conf.json
echo "    \"access\": \"/home/vpsadmin/xray_log/access.log\", // 访问记录" >> ./Xray-${Version}/conf.json
echo "    \"error\": \"/home/vpsadmin/xray_log/error.log\" // 错误记录" >> ./Xray-${Version}/conf.json
echo "  }," >> ./Xray-${Version}/conf.json
echo "  // 2_DNS 设置" >> ./Xray-${Version}/conf.json
echo "  \"dns\": {" >> ./Xray-${Version}/conf.json
echo "    \"servers\": [" >> ./Xray-${Version}/conf.json
echo "      \"https+local://1.1.1.1/dns-query\", // 首选 1.1.1.1 的 DoH 查询，牺牲速度但可防止 ISP 偷窥" >> ./Xray-${Version}/conf.json
echo "      \"localhost\"" >> ./Xray-${Version}/conf.json
echo "    ]" >> ./Xray-${Version}/conf.json
echo "  }," >> ./Xray-${Version}/conf.json
echo "  // 3*分流设置" >> ./Xray-${Version}/conf.json
echo "  \"routing\": {" >> ./Xray-${Version}/conf.json
echo "    \"domainStrategy\": \"IPIfNonMatch\"," >> ./Xray-${Version}/conf.json
echo "    \"rules\": [" >> ./Xray-${Version}/conf.json
echo "      // 3.1 防止服务器本地流转问题：如内网被攻击或滥用、错误的本地回环等" >> ./Xray-${Version}/conf.json
echo "      {" >> ./Xray-${Version}/conf.json
echo "        \"type\": \"field\"," >> ./Xray-${Version}/conf.json
echo "        \"ip\": [" >> ./Xray-${Version}/conf.json
echo "          \"geoip:private\" // 分流条件：geoip 文件内，名为\"private\"的规则（本地）" >> ./Xray-${Version}/conf.json
echo "        ]," >> ./Xray-${Version}/conf.json
echo "        \"outboundTag\": \"block\" // 分流策略：交给出站\"block\"处理（黑洞屏蔽）" >> ./Xray-${Version}/conf.json
echo "      }," >> ./Xray-${Version}/conf.json
echo "      {" >> ./Xray-${Version}/conf.json
echo "        // 3.2 防止服务器直连国内" >> ./Xray-${Version}/conf.json
echo "        \"type\": \"field\"," >> ./Xray-${Version}/conf.json
echo "        \"ip\": [\"geoip:cn\"]," >> ./Xray-${Version}/conf.json
echo "        \"outboundTag\": \"block\"" >> ./Xray-${Version}/conf.json
echo "      }," >> ./Xray-${Version}/conf.json
echo "      // 3.3 屏蔽广告" >> ./Xray-${Version}/conf.json
echo "      {" >> ./Xray-${Version}/conf.json
echo "        \"type\": \"field\"," >> ./Xray-${Version}/conf.json
echo "        \"domain\": [" >> ./Xray-${Version}/conf.json
echo "          \"geosite:category-ads-all\" // 分流条件：geosite 文件内，名为\"category-ads-all\"的规则（各种广告域名）" >> ./Xray-${Version}/conf.json
echo "        ]," >> ./Xray-${Version}/conf.json
echo "        \"outboundTag\": \"block\" // 分流策略：交给出站\"block\"处理（黑洞屏蔽）" >> ./Xray-${Version}/conf.json
echo "      }" >> ./Xray-${Version}/conf.json
echo "    ]" >> ./Xray-${Version}/conf.json
echo "  }," >> ./Xray-${Version}/conf.json
echo "  // 4*入站设置" >> ./Xray-${Version}/conf.json
echo "  // 4.1 这里只写了一个最简单的 vless+xtls 的入站，因为这是 Xray 最强大的模式。如有其他需要，请根据模版自行添加。" >> ./Xray-${Version}/conf.json
echo "  \"inbounds\": [" >> ./Xray-${Version}/conf.json
echo "    {" >> ./Xray-${Version}/conf.json
echo "      \"port\": 443," >> ./Xray-${Version}/conf.json
echo "      \"protocol\": \"vless\"," >> ./Xray-${Version}/conf.json
echo "      \"settings\": {" >> ./Xray-${Version}/conf.json
echo "        \"clients\": [" >> ./Xray-${Version}/conf.json
echo "          {" >> ./Xray-${Version}/conf.json
echo "            \"id\": \"\", // 填写你的 UUID" >> ./Xray-${Version}/conf.json
echo "            \"flow\": \"xtls-rprx-vision\"," >> ./Xray-${Version}/conf.json
echo "            \"level\": 0," >> ./Xray-${Version}/conf.json
echo "            \"email\": \"vpsadmin@yourdomain.com\"" >> ./Xray-${Version}/conf.json
echo "          }" >> ./Xray-${Version}/conf.json
echo "        ]," >> ./Xray-${Version}/conf.json
echo "        \"decryption\": \"none\"," >> ./Xray-${Version}/conf.json
echo "        \"fallbacks\": [" >> ./Xray-${Version}/conf.json
echo "          {" >> ./Xray-${Version}/conf.json
echo "            \"dest\": 80 // 默认回落到防探测的代理" >> ./Xray-${Version}/conf.json
echo "          }" >> ./Xray-${Version}/conf.json
echo "        ]" >> ./Xray-${Version}/conf.json
echo "      }," >> ./Xray-${Version}/conf.json
echo "      \"streamSettings\": {" >> ./Xray-${Version}/conf.json
echo "        \"network\": \"tcp\"," >> ./Xray-${Version}/conf.json
echo "        \"security\": \"tls\"," >> ./Xray-${Version}/conf.json
echo "        \"tlsSettings\": {" >> ./Xray-${Version}/conf.json
echo "          \"alpn\": \"http/1.1\"," >> ./Xray-${Version}/conf.json
echo "          \"certificates\": [" >> ./Xray-${Version}/conf.json
echo "            {" >> ./Xray-${Version}/conf.json
echo "              \"certificateFile\": \"/home/vpsadmin/xray_cert/xray.crt\"," >> ./Xray-${Version}/conf.json
echo "              \"keyFile\": \"/home/vpsadmin/xray_cert/xray.key\"" >> ./Xray-${Version}/conf.json
echo "            }" >> ./Xray-${Version}/conf.json
echo "          ]" >> ./Xray-${Version}/conf.json
echo "        }" >> ./Xray-${Version}/conf.json
echo "      }" >> ./Xray-${Version}/conf.json
echo "    }" >> ./Xray-${Version}/conf.json
echo "  ]," >> ./Xray-${Version}/conf.json
echo "  // 5*出站设置" >> ./Xray-${Version}/conf.json
echo "  \"outbounds\": [" >> ./Xray-${Version}/conf.json
echo "    // 5.1 第一个出站是默认规则，freedom 就是对外直连（vps 已经是外网，所以直连）" >> ./Xray-${Version}/conf.json
echo "    {" >> ./Xray-${Version}/conf.json
echo "      \"tag\": \"direct\"," >> ./Xray-${Version}/conf.json
echo "      \"protocol\": \"freedom\"" >> ./Xray-${Version}/conf.json
echo "    }," >> ./Xray-${Version}/conf.json
echo "    // 5.2 屏蔽规则，blackhole 协议就是把流量导入到黑洞里（屏蔽）" >> ./Xray-${Version}/conf.json
echo "    {" >> ./Xray-${Version}/conf.json
echo "      \"tag\": \"block\"," >> ./Xray-${Version}/conf.json
echo "      \"protocol\": \"blackhole\"" >> ./Xray-${Version}/conf.json
echo "    }" >> ./Xray-${Version}/conf.json
echo "  ]" >> ./Xray-${Version}/conf.json
echo "}" >> ./Xray-${Version}/conf.json
## 构建服务
### 日志目录
mkdir ~/xray_log
touch ~/xray_log/access.log
touch ~/xray_log/error.log
chmod a+w ~/xray_log/*.log
systemctl start xray
systemctl status xray
systemctl enable xray
## 防火墙端口打开
## 保存防火墙策略
iptables-save
apt -y install iptables-persistent
service netfilter-persistent save

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
echo "    \"method\": \"${encryptMethod}\", " >> ${HOME}/ss-service/ss-service-config.json
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
systemctl enable ss-service.service
systemctl enable kcptun-service.service
systemctl stop ss-service.service
systemctl stop kcptun-service.service
systemctl start ss-service.service
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
echo "ExecStart=/snap/bin/shadowsocks-libev.ss-server -s ${IP} -p ${ssPort} -k ${password} -m ${encryptMethod}" >> ${HOME}/ss-service/sslibev-service.service
echo "[Install] " >> ${HOME}/ss-service/sslibev-service.service
echo "WantedBy=multi-user.target " >> ${HOME}/ss-service/sslibev-service.service
cp ${HOME}/ss-service/sslibev-service.service /etc/systemd/system/
systemctl daemon-reload
#systemctl enable sslibev-service.service
#systemctl stop sslibev-service.service
#systemctl start sslibev-service.service
#systemctl status sslibev-service.service

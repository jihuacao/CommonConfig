# openssh-server
## 安装ssh
RUN \
--mount=type=bind,target=/root/DockerContext,source=DockerContext,rw \
echo 'config ssh' \
&& apt -y install openssh-server \
&& mkdir -p /var/run/sshd \
## 配置ssh
&& echo 'root:passwd'|chpasswd \
&& echo 'PermitRootLogin yes' >>/etc/ssh/sshd_config \
## ssh自启
### 构建自启脚本
&& echo '#!/bin/bash' >>~/run_sshd.sh \
&& echo 'LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")' >>~/run_sshd.sh \
&& echo 'echo "[$LOGTIME] startup run..." >>~/run_sshd.log' >>~/run_sshd.sh \
&& echo 'service ssh start >>/root/run_sshd.log' >>~/run_sshd.sh \
&& chmod +x ~/run_sshd.sh \
### 在~/.bashrc中调用自启脚本
&& echo "if [ -f ~/run_sshd.sh ]; then" >> ~/.bashrc \
&& echo "    ~/run_sshd.sh" >> ~/.bashrc \
&& echo "fi" >> ~/.bashrc \
## 拷贝认证
&& mkdir -p ~/.ssh \
&& cp ~/DockerContext/ssh/authorized_keys ~/.ssh \
&& echo "end"
# ops: config the pip
RUN \
--mount=type=cache,target=/root/.cache \
#--mount=type=bind,target=/root/.cache/pip,source=DockerContext/pip-cache,rw \
mkdir ~/.pip \
#&& cp /root/.cache/pip/test.md ~/ \
## 换源
&& echo '[global]' >> ~/.pip/pip.conf \
&& echo 'index-url=http://mirrors.aliyun.com/pypi/simple/' >> ~/.pip/pip.conf \
&& echo 'extra-index-url=http://pypi.mirrors.ustc.edu.cn/simple/' >> ~/.pip/pip.conf \
&& echo '                http://pypi.douban.com/simple/' >> ~/.pip/pip.conf \
&& echo '                https://pypi.tuna.tsinghua.edu.cn/simple/' >> ~/.pip/pip.conf \
## 修改缓存地址
&& echo '[install]' >> ~/.pip/pip.conf \
&& echo 'trusted-host=mirrors.aliyun.com' >> ~/.pip/pip.conf \
&& echo '             pypi.mirrors.ustc.edu.cn' >> ~/.pip/pip.conf \
&& echo '             pypi.douban.com' >> ~/.pip/pip.conf \
&& echo '             pypi.tuna.tsinghua.edu.cn' >> ~/.pip/pip.conf \
## 升级pip
&& pip install --upgrade pip \
&& echo 'end'
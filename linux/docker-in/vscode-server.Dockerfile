# config the vscode
## config the vscode-server
RUN \
--mount=type=bind,target=/root/DockerContext,source=DockerContext,rw \
echo 'config vscode-server' \
&& mkdir -p ~/.vscode-server/ \
&& mkdir -p ~/.vscode-server/bin/ \
### vscode-server服务端拷贝 todo: vscode-server commit-id需要自适应
&& tar -xvf ~/DockerContext/.vscode-server/x64_linux/bin.tar.gz -C ~/.vscode-server \
### vscode-server data拷贝
&& tar -xvf ~/DockerContext/.vscode-server/x64_linux/data.tar.gz -C ~/.vscode-server \
### vscode-server extensions拷贝
&& tar -xvf ~/DockerContext/.vscode-server/x64_linux/extensions.tar.gz -C ~/.vscode-server \
&& echo 'config vscode-server done'
# !/bin/bash
Proxy="ProxyCommand=ncat --proxy-type socks4 --proxy-auth inspur:Inspur111222 --proxy 10.110.63.27:11080"
DeployUserRoot="/home/common/caojihua"
DeployTargetRoot="/home/common/caojihua"
DeployTargetPort="22"
DeployTargetUser="root"
DockerImageRoot="${DeployUserRoot}/DockerImage"
RootDir=$(cd $(dirname $0); pwd)
ProjectRoot=""
ImagePrefix="cjh"
DockerContext=""
DockerContainerMap=""

DeployOps=""
DeploySource=""
DeployLabel=""
DockerDeploy=0
SSHOption="ProxyCommand=ncat --proxy-type <proxy_type> --proxy-auth <proxy_user>:<proxy_passwd> \
--proxy <proxy_ip>:<proxy_port> <target_ip> <target_port>"

BuildDockerContext=0
BuildDockerContainerMap=0
usage(){
    echo 'help message'
    echo '主旨:使用多个Dockerfile.[ops|test|dev].<version>来迭代镜像版本，\n \
    出现镜像更新则使用新的Dockerfile，此Dockerfile就可以使用旧的Image进行生成，节省时间'
    echo '--image-prefix 指定Image的前缀\n \
    ImagePrefix会使用image-prefix\n \
    生成的Image会以以下格式命名\n \
    <ImagePrefix>/<ImageName>:<ImageTag>'
    echo '--docker-context 指定作为build image使用的context路径'
    echo '--docker-container-map 指定包含即将被使用于进行文件映射的文件夹的路径'
    echo '--test-dockerfile 指定使用的目标Dockerfile进行生成Image，这在编写测试时很有用'
    echo '--rm-the-old-image 指定时将会删除旧的image，当存储介质足够时\n \
    **不建议删除，因为此工具就是使用空间换开发时间，如果删除了，下次用到就又浪费时间了**'

    echo '--deploy 发布操作，指定目标操作（那么肯定涉及到source，proxy，target），支持
Image|LoadImage|RMContainer|RMImage|CreateContainer|ContainerMap|ProjectSrc|Data
    * Image: deploy image 到目标机器上
    * RMContainer：删除目标机器上基于Image的容器
    * RMImage:删除目标机器上于Image同系列的镜像（同个工程项目为同系列）
    * LoadImage：在目标机器上加载Image
    * CreateContainer:在目标机器上构建Image的容器
    '
    echo '--deploy-source 表示部署源，可以是离线的image文件，可以是server的image，也可以是远程的image'
    echo '--deploy-target 表示部署行为的目标机器'
    echo '--docker-deploy 当指定时，表示进行基于docker的部署行动，获取image->传输image->加载image'
    echo '--deploy-create-container-command 指定用于在target上构建容器的命令'

    echo '--build-docker-context 当指定时，将进行DockerContext的构建，下载一些docker常见使用的库'

    echo '--build-docker-container-map 当指定时，将进行DockerContainerMap的构建,
        * 提取vscode-server'
}
ARGS=`getopt \
    -o h \
    --long help,project-root: \
    --long image-prefix: \
    --long test-dockerfile: \
    --long docker-context: \
    --long docker-container-map: \
    --long docker-deploy \
    --long deploy-source: \
    --long deploy-target: \
    --long deploy-create-container-command: \
    --long build-docker-context \
    -n 'example.bash' -- "$@"`
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "${ARGS}"
while true ; do
    case "$1" in
        --docker-context)
            DockerContext=$(cd $2; pwd); echo "DockerContext=${DockerContext}"; shift 2
            ;;
        --docker-container-map)
            DockerContainerMap=$(cd $2; pwd); echo "DockerContainerMap=${DockerCOntainerMap}"; shift 2
            ;;
        -c|--clong)
            case "$2" in
                "") echo "Option $1, no argument"; shift 2;;
                *)  echo "Option $1, argument $2" ; shift 2;;
            esac
            ;;
        --image-prefix)
            if [[ $2=="" ]]; then
                echo "specify the image-prefix with \"\", check the help message, \nkeep ImagePrefix as ${ImagePrefix}"
                shift 2
            else
                ImagePrefix=$2; shift 2
            fi
            ;;
        --project-root)
            ProjectRoot=$2; shift 2
            ;;
        --test-dockerfile)
            TestDockerfile=$2; shift 2
            ;;
        --docker-deploy)
            DockerDeploy=1; shift 1
            ;;
        --deploy)
            if [[ ${DeployOps} == "" ]]; then 
                DeployOps=("$2")
            else
                DeployOps=("${DeployOps[@]} $2")
            fi
            shift 2
            ;;
        --deploy-source)
            DeploySource=${2}; shift 2
            echo "set DeploySource: ${DeploySource}"
            DeployLabel=$(echo ${DeploySource} | sed 's/\//-/g')
            DeployLabel=$(echo ${DeployLabel%:1.0*})
            echo "set DeployLabel: ${DeployLabel}"
            ;;
        --deploy-target)
            DeployTarget=${2}; shift 2
            ;;
        --deploy-create-container-command)
            DeployCreateContainerCommand=${2}; shift 2
            ;;
        --build-docker-context)
            BuildDockerContext=1; shift 1
            ;;
        --build-docker-container-map)
            BuildDockerContainerMap=1; shift 1
            ;;
        -h|--help)
            usage; exit 1
            ;;
        --)
            shift 1; break
            ;;
        -)
            shift 1; break
            ;;
        *)
            echo "Internal error!"; exit 1
            ;;
    esac
done
echo "Remaining arguments:"
for arg do
   echo '--> '"\`$arg'" ;
done

if [[ ${BuildDockerContext} -eq 1 ]]; then
    if [[ ${DockerContext} == "" ]]; then
        echo "specify the docker-context directory"
    fi
    cd ${HOME} && tar -cvf ${DockerContainerMap}/.vscode-server/x64_linux/vscode-server.tar.gz ./.vscode-server
fi

if [[ ${BuildDockerContainerMap} -eq 1 ]]; then
    if [[ ${DockerContainerMap} == "" ]]; then
        echo "specify the docker-container-map directory"
    fi
    cd ${HOME} && tar -cvf ${DockerContainerMap}/.vscode-server/x64_linux/vscode-server.tar.gz ./.vscode-server
fi

for((i=0;i<${#DeployOps[@]};i++)){
    if [[ ${DeployOps[i]} == "Image" ]]; then
        docker save -o ${DockerImageRoot}/${DeployLabel}.tar.gz ${DeployTarget}
        scp -o "${Proxy} ${DoployTarget} ${DeployTargetPort}" ${DOckerImageRoot}/${DeployLabel}.tar.gz ${DeployTargetUser}@${DeployTarget}:${DeployTargetRoot}/${DeployLabel}.tar.gz
    elif [[ ${DeployOps[i]} == "LoadImage" ]]; then
        ssh -o "${Proxy} ${DoployTarget} ${DeployTargetPort}" ${DeployTargetUser}@${DeployTarget} "docker load -i ${DeployTargetRoot}/${DeployLabel}.tar.gz"
    elif [[ ${DeployOps[i]} == "RMContainer" ]]; then
        echo "ssh -o "${Proxy} ${DoployTarget} ${DeployTargetPort}" ${DeployTargetUser}@${DeployTarget} "docker container stop ${DeployLabel} && docker container rm ${DeployLabel}""
    elif [[ ${DeployOps[i]} == "RMImage" ]]; then
        echo 'no supported'
    elif [[ ${DeployOps[i]} == "CreateContainer" ]]; then
        echo "ssh -o "${Proxy} ${DoployTarget} ${DeployTargetPort}" ${DeployTargetUser}@${DeployTarget} "docker create -it -p 10084:22 --ipc host --name ${DeployLabel} --gpus all -v ${DeployUserRoot}:/root/workspace -v ${DeployUserRoot}/DockerContainerMap/torch:/root/.cache/torch -v ${DeployUserRoot}/DockerContainerMap/vscode/x64_linux/.vscode-server:/root/.vscode-server -t ${DeploySource} /bin/bash""
    else
        echo "unsupported deploy-ops: ${DeployOps[i]}"
    fi
}

if [[ ${#DeployOps[@]} -gt 0 ]]; then
    for((i=0;i<${#DeployOps[@]};i++)){
        if [[ ${DeployOps[i]} == "Image" ]];then
            docker save -o ${HOME}/.cache/${} ${DeploySource}
        fi
    }
fi

if [[ ${DeployDockerContainerMap} -eq 1 ]]; then
    if [[ ${DockerContainerMap} == "" ]]; then
        echo "specify the docker-container-map directory"
    fi
    cd $(dirname ${DockerContainerMap}) && tar -cvf 
fi

if [[ ${DockerDeploy} -eq 1 ]]; then
    ImageName=${DeploySource}
    ContainerName=$(echo ${ImageName%\:*})
    ContainerName=${ContainerName//\//}
    echo "todo: save the image: docker save -o ${HOME}/.cache/${ContainerName}.tar.gz ${ImageName}"
    echo "todo: scp image file to target machine: scp -o "ProxyCommand=ncat --proxy-type socks4 --proxy-auth inspur:Inspur111222 --proxy 10.110.63.27:11080 ${DeployTarget} 22" ${HOME}/.cache/${ContainerName}.tar.gz root@${DeployTarget}:/root/.cache/"
    echo "todo: load image file in target machine: ssh -o \
    "ProxyCommand=ncat --proxy-type socks4 --proxy-auth inspur:Inspur111222 --proxy 10.110.63.27:11080 ${DeployTarget} 22" \
    root@${DeployTarget} \
    "docker load -i root/.cache/${ContainerName}.tar.gz \
    && docker create -it -p 10084:22 --ipc host --name ${ContainerName} --gpus all -v /home/common/caojihua:/root/workspace -t ${ImageName} /bin/bash""
    echo "todo: check the same project image in target machine"
    echo "todo: if has check the container"
    echo "todo: stop the container"
    echo "todo: generate new container base new image"
    echo "todo: delete the old container"
    echo "todo: delete the old image"
fi

# todo: offline station
# * 使用docker方式
#   * 在online station生成docker image
#     * image with version
#     * image with strong label
#   * online docker image->offline station
#   * offline station docker server load image
# todo: online && high safety level station
#   todo: user seperated-using vscode remote-ssh(port avaliable)
#   todo: non user seperated-using docker && vim
# cp ${RootDir}/.vimrc
# todo: online && low safety level station
#   todo: user seperated-using vscode remote-ssh(port avaliable)
#   todo: non user seperated-using docker && vscode remote-ssh(port avaliable)
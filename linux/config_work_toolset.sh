# !/bin/bash
RootDir=$(cd $(dirname $0); pwd)
ProjectRoot=""
ImagePrefix="cjh"
DockerContext=""
SSHOption="ProxyCommand=ncat --proxy-type <proxy_type> --proxy-auth <proxy_user>:<proxy_passwd> \
--proxy <proxy_ip>:<proxy_port> <target_ip> <target_port>"
usage(){
    echo 'help message'
    echo '主旨:使用多个Dockerfile.[ops|test|dev].<version>来迭代镜像版本，\n \
    出现镜像更新则使用新的Dockerfile，此Dockerfile就可以使用旧的Image进行生成，节省时间'
    echo '--image-prefix 指定Image的前缀\n \
    ImagePrefix会使用image-prefix\n \
    生成的Image会以以下格式命名\n \
    <ImagePrefix>/<ImageName>:<ImageTag>'
    echo '--project-root 指定工程目录，ImageName会以工程目录文件夹名命名'
    echo '--test-dockerfile 指定使用的目标Dockerfile进行生成Image，这在编写测试时很有用'
    echo '--rm-the-old-image 指定时将会删除旧的image，当存储介质足够时\n \
    **不建议删除，因为此工具就是使用空间换开发时间，如果删除了，下次用到就又浪费时间了**'
    echo '--docker-deploy 当指定时，表示进行基于docker的部署行动，获取image->传输image->加载image'
    echo '--docker-deploy-source 表示部署源，可以是离线的image文件，可以是server的image，也可以是远程的image'
    echo '--docker-deploy-target 表示部署行为的目标机器'
    echo '--ssh-proxy specify the <proxy_ip>:<proxy_port>'
    echo '--ssh-proxy-type specify the'
}
ARGS=`getopt \
    -o h\
    --long help,project-root: \
    --long image-prefix: \
    --long test-dockerfile: \
    --long docker-context: \
    -o docker-deploy \
    --long docker-deploy-source: \
    --long docker-deploy-target: \
    --long ssh-option: \
    --long ssh-proxy: \
    --long ssh-proxy-type: \
    --long ssh-proxy-auth: \
    -n 'example.bash' -- "$@"`
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "${ARGS}"
while true ; do
    case "$1" in
        --docker-context)
            DockerContext=$(cd $2; pwd)
            echo "DockerContext=${DockerContext}"
            shift 2
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

# safety check
if [[ ${DockerContext}=="" ]]; then
    echo "you should specify the docker-context"
    exit 1
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
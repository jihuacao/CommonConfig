ConfigCCPP=0
CmakeVersion=3.19.0
usage(){
    echo "help message"
    echo "--nvidia: config nvidia context while set"
    echo "--nvidia-cuda-version set the cuda version"
    echo "--nvidia-cudnn-version set the cudnn version"
    echo "--nvidia-nccl"
}
ARGS=`getopt \
    -o h \
    --long help, \
    --long config_c_cpp \
    --long cmake_version:: \
    --long nvidia \
    --long nvidia-cuda-version:: \
    --long nvidia-cudnn-version:: \
    --long nvidia-nccl \
    --long nvidia-tensort \
    -n 'example.bash' -- "$@"`
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "${ARGS}"
while true ; do
    case "$1" in
        --config_c_cpp)
            echo "config c_cpp evnironment"; ConfigCCPP=1; shift 1 ;;
        --cmake_version)
            echo "cmake version: $2"; CmakeVersion=$2; shift 2 ;;
        --nvidia)
            echo "config nvidia context"; ConfigNvidia=1; shift 1 ;; 
        --nvidia-cuda-version)
            echo ""
        -h|--help)
            usage; exit 1 ;;
        --)
            shift 1; break ;;
        -)
            shift 1; break ;;
        *)
            echo "Internal error!"; exit 1 ;;
    esac
done
echo "Remaining arguments:"
for arg do
   echo '--> '"\`$arg'" ;
done

# 下载cmake源码
wget https://github.com/Kitware/CMake/releases/download/v${CmakeVersion}/cmake-${CmakeVersion}-SHA-256.txt
while 1; do
    wget -c https://github.com/Kitware/CMake/releases/download/v${CmakeVersion}/cmake-${CmakeVersion}-Linux-x86_64.sh
done

wget https://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda_10.2.89_440.33.01_linux.run
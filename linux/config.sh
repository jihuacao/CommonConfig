ConfigCCPP=0
CmakeVersion=3.19.0
usage(){
    echo 'help message'
}
ARGS=`getopt \
    -o h \
    --long help, \
    --long config_c_cpp \
    --long cmake_version
    -n 'example.bash' -- "$@"`
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "${ARGS}"
while true ; do
    case "$1" in
        --config_c_cpp)
            echo "config c_cpp evnironment"; ConfigCCPP=1; shift 1; break ;;
        --cmake_version)
            echo "cmake version: $2"; CmakeVersion=$2; shift 2; break ;;
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
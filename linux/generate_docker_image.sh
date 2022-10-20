# 自动化构建dev|test|ops镜像
#   * base是必然需要的基础Image
#   * 脚本需要适应Dockerfile编写调试
#     * 可以针对某个更改的Dockerfile.*.*进行测试
## Dockerfile命名格式使用[base|ops|dev|test].<version_id>.Dockerfile
RootDir=$(cd $(dirname $0); pwd)
ExecDir=$(pwd)
DockerRoot=""
ImagePrefix="cjh"
ImageName=""
UseGit=0
StageKeepInVersionFilter=()
BuildOptions=""
params=""
for x in "$*"; do
    params="${params}${x}"
done
called="call: bash ${0} ${params}"
usage(){
    echo 'help message'
    echo '主旨:补全multi_stage的功能，支持多个Dockerfile生成一个，达到多分枝的目的，同时避免由于修改layer而耗费大量时间'
    echo 'dockerfile集合命名规范：<stage>.v<version>.Dockerfile'
    echo '--image-prefix 指定Image的前缀\n \
    ImagePrefix会使用image-prefix\n \
    生成的Image会以以下格式命名\n \
    <ImagePrefix>/<ImageName>:<ImageTag>'
    echo '--image-name 指定ImageName，默认为""'
    echo '--docker-root 指定存储Dockerfile的路径'
    echo '--target-stage 指定目标阶段base-ops-dev-test|base-ops-test|base-ops-dev'
    echo '--target-version 指定目标文件版本'
    echo '--use-git 使用git版本信息优化命名规则，前提是host上有git'
    echo '--stage-keep-in-version-filter 指定stage不会被version_filter过滤掉'
    echo '--build-options 只能怪在build中使用的参数'
}
ARGS=`getopt \
    -o h\
    --long help, \
    --long docker-root:: \
    --long image-prefix:: \
    --long image-name:: \
    --long target-stage:: \
    --long target-version:: \
    --long use-git \
    --long build-options:: \
    --long stage-keep-in-version-filter:: \
    -n 'example.bash' -- "$@"`
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "${ARGS}"
while true ; do
    case "$1" in
        -c|--clong)
            case "$2" in
                "") echo "Option $1, no argument";;
                *)  echo "Option $1, argument $2" ;;
            esac
            shift 2
            ;;
        --image-prefix)
            echo "specify the ImagePrefix as $2"; ImagePrefix=$2; shift 2
            ;;
        --docker-root)
            echo "specify DockerRoot as $2"; DockerRoot=$2; shift 2
            ;;
        --image-name)
            echo "specify ImageName as $2"; ImageName=$2; shift 2
            ;;
        --target-stage)
            echo "specify TargetStage as $2"; TargetStage=$2; shift 2
            ;;
        --target-version)
            echo "specify TargetVersion as $2"; TargetVersion=$2; shift 2
            ;;
        --use-git)
            echo "git would be used"; UseGit=1; shift 1
            ;;
        --build-options)
            echo "build options: $2"; BuildOptions=$2; shift 2
            ;;
        --stage-keep-in-version-filter)
            echo "add stage keep in version filter: $2"; StageKeepInVersionFilter=($2 "${StageKeepInVersionFilter[@]}"); shift 2 ;;
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

if [[ ${DockerRoot} == "" ]]; then
    echo "docker-root needed: see the help message"
    exit 1
fi
if [[ ${ImageName} == "" ]]; then
    echo "image-name needed: see the help message"
fi

##@brief
# @note 返回Dockerfile的类型
get_type(){
    echo "get_type"
}

##@brief
# @note 返回Dockerfile的版本
get_version(){
    file_name="$1"
    vd=$(echo ${file_name##*v}) # 贪婪从匹配字符"v"开始向左删除字符串
    v=$(echo ${vd%.Dockerfile*}) # 非贪婪从匹配字符".Dockerfile"开始向右删除字符串
    echo "${v}"
}

version_comp(){
    local version1=$1
    local version2=$2
    version_array1=(${version1//./ })
    version_array2=(${version2//./ })
    if [[ ${#version_array1[@]} != ${#version_array2[@]} ]]; then
        echo "version_comp between two version which are not the same len"
        exit 1
    fi
    for((i=0;i<${#version_array1[@]};i++)){
        one=${version_array1[i]}
        two=${version_array2[i]}
        if [[ ${one} -eq ${two} ]];then
            continue
        elif [[ ${one} -gt ${two} ]];then
            echo "gt"
            exit 0
        else
            echo "lt"
            exit 0
        fi
    }
    echo "eq"
}

sort_by_version(){
    local files=($1)
    for((i=0;i<${#files[@]};i++)){
        for((j=0;j<${#files[@]}-i-1;j++)){
            verj=$(get_version "${files[j]}")
            #echo "verj:${verj}"
            verjp=$(get_version "${files[j+1]}")
            #echo "verjp:${verjp}"
            rel=$(version_comp "${verj}" "${verjp}")
            if [[ ${rel} == "gt" ]]; then
                tmp=${files[j]}
                files[j]=${files[j+1]}
                files[j+1]=$tmp
            fi
        }
    }
    echo "${files[@]}"
}

get_stage(){
    local file_name=$1
    stage=$(echo ${file_name%%.v*}) # 贪婪从匹配".v"字符开始向右删除字符串
    echo "${stage}"
}

stage_comp(){
    local stage1=$1
    local stage2=$2
    local stage_order=($3)
    for((i=0;i<${#stage_order[@]};i++)){
        if [[ ${stage1} == ${stage_order[i]} ]];then
            echo "lt"
            exit 0
        elif [[ ${stage2} == ${stage_order[i]} ]];then
            echo "gt"
            exit 0
        else
            continue
        fi
    }
    echo "eq"
}

sort_by_stage(){
    local files=($1)
    local target_stage_order=($2)
    for((i=0;i<${#files[@]};i++)){
        for((j=i;j<${#files[@]};j++)){
            verj=$(get_version "${files[i]}")
            verjp=$(get_version "${files[j]}")
            # echo "${files[j]} vs ${files[j+1]}" # debug
            vrel=$(version_comp "${verj}" "${verjp}")
            if [[ ${vrel} != "eq" ]]; then
                break
            fi
            stagej=$(get_stage "${files[i]}")
            stagejp=$(get_stage "${files[j]}")
            three_temp="${target_stage_order[@]}"
            srel=$(stage_comp "${stagej}" "${stagejp}" "${three_temp}")
            # echo "${srel} ${files[j]} vs ${files[j+1]}" # debug
            if [[ ${srel} == "gt" ]];then
                tmp=${files[i]}
                files[i]=${files[j]}
                files[j]=$tmp
            fi
        }
    }
    echo "${files[@]}"
}

filter_by_target(){
    files=($1)
    stages=($2)
    result=""
    for((i=0;i<${#files[@]};i++)){
        stage=$(get_stage "${files[i]}")
        for((j=0;j<${#stages[@]};j++)){
            if [[ ${stage} == ${stages[j]} ]];then
                if [[ ${result} == "" ]];then
                    result="${files[i]}"
                else
                    result="${result} ${files[i]}"
                fi
            fi
        }
    }
    echo "${result}"
}

filter_by_version(){
    files=($1)
    version=$2
    result=""
    for((i=0;i<${#files[@]};i++)){
        stage=$(get_stage "${files[i]}")
        keep=0
        for((j=0;j<${#StageKeepInVersionFilter[@]};j++)){
            if [[ ${stage} == ${StageKeepInVersionFilter[j]} ]]; then
                keep=1
            fi
        }
        if [[ ${keep} == "1" ]]; then
            result="${result} ${files[i]}"
            continue
        fi
        verf=$(get_version "${files[i]}")
        #echo "verjp:${verjp}"
        rel=$(version_comp "${verf}" "${version}")
        if [[ ${rel} != "gt" ]]; then
            if [[ ${result} == "" ]];then
                result="${files[i]}"
            else
                result="${result} ${files[i]}"
            fi
        fi
    }
    echo "${result}"
}

generate_tag(){
    files=($1)
    use_git=$2
    docker_root=$3

    version=""
    newest_commit_id=""
    state=""

    # 确定文件标志版本
    version=$(get_version ${files[${#files[@]}-1]})
    # 确定目标Dockerfile列表中最晚commit的那个commit id（short）
    commit_ids=($(echo $(cd ${docker_root}; git log --pretty=format:"%h" ./))) # 获取存储dockerfile目录的短commit id列表
    for((i=0;i<${#commit_ids[@]}-1;i++)){
        changed_files=($(echo $(cd ${docker_root}; git diff --no-commit-id --name-only --relative ${commit_ids[i+1]} ${commit_ids[i]} ./)))
        for((j=0;j<${#changed_files[@]};j++)){
            for((k=0;k<${#files[@]};k++)){
                if [[ ${changed_files[j]} == ${files[k]} ]];then
                    newest_commit_id=${commit_ids[i]}
                    break
                fi
            }
            if [[ ${newest_commit_id} != "" ]];then
                break
            fi
        }
        if [[ ${newest_commit_id} != "" ]];then
            break
        fi
    }
    # todo: 异常情况还得考虑
    #   * 目标Dockerfile列表成员完全没有commit历史
    #   * 目标Dockerfile列表成员只有一个commit历史(由于是通过两个commit id进行git-diff比较出来的，所以这种情况存在)
    # **目前简单的将newest_commit_id置为none**
    if [[ ${newest_commit_id} == "" ]]; then
        newest_commit_id="none"
        #if [[ ${#commit_ids[@]} -eq 0 ]]; then
        #    newest_commit_id="none"
        #elif [[ ${#commit_ids[@]} -eq 1 ]]; then
        #    newest_commit_id=${commit_ids[0]}
        #else
        #    newest_commit_id
        #fi
        #newest_commit_id=${commit_ids}
    fi
    # 确定相关文件是否存在未commit更改
    no_commited_files=($(cd ${docker_root}; git diff --no-commit-id --name-only --relative -r ./))
    for((i=0;i<${#no_commited_files[@]};i++)){
        for((j=0;j<${#files[@]};j++)){
            if [[ ${no_commited_files[i]} == ${files[j]} ]]; then
                state="uncommited"
            fi
        }
    }
    if [[ ${state} == "" ]]; then
        state="commited"
    fi

    tag=${version}-${newest_commit_id}-${state}
    echo ${tag} # debug
}

##@brief
# @note 检查目标Dockerfile的基础Dockerfile
# @param[in] 目标Dockerfile
# @param[in] 所有Dockerfile
# @ret 
#   如果目标Dockerfile的基础Dockerfile存在，则返回基础Dockerfile
#   如果目标Dockerfile已经是最低层Dockerfile，则返回NULL
check_lower(){
    echo ""
}

##@brief
# @note 检查目标Dockerfile的基础Dockerfile
# @param[in] 目标Dockerfile
# @param[in] 所有Dockerfile
# @ret 
#   如果目标Dockerfile的上层Dockerfile存在，则返回上层Dockerfile
#   如果目标Dockerfile已经是最高层Dockerfile，则返回NULL
check_upper(){
    echo ""
}

##@brief
# @note 检查目标Dockerfile的是否存在最新
#   * Dockerfile被更改，没有commit，如果没有commit，则Image的TAG为：[dev|ops|test].<version>.hash git diff Dockerfile
#       * 存在最新Image
#       * 不存在最新Image
#   * Dockerfile被更改，已经commit，则Image的TAG为[dev|ops|test].<version>.short_commit_id
#       * 存在最新Image
#       * 不存在最新Image
# @ret 返回是否最新
#   * 如果为最新，返回YES
#   * 如果非最新，返回NO
check_newest(){
    echo ""
}

# important: 注意read line将文件中的字符\(backslash)视为同一行(这里使用read -r取消\作为换行符，否则会被拼接起来)
extract_file(){
    source=$1
    target=$2
    extracted=""
    # important: 由于while do结构是当下一行存在时才写入这一行，会漏写最后一行，因此增加了|| [ -n "$line" ]
    cat ${source} | while read -r line || [ -n "$line" ]
    do
        result=$(echo ${line}|grep "@import:")
        if [[ ${result} != "" ]]; then
            echo "get the import: $line"
            file=${line##"@import:"}
            echo "# extract ${DockerRoot}/${file} to ${target}" >> ${target}
            file_extracted=$(extract_file ${DockerRoot}/${file} $target)
        else
            echo $line >> $target
        fi
    done
}

stage_order=(${TargetStage//-/ })
echo "stage order: ${stage_order[@]}"

# todo: check target dockerfile is exist or not while test-dockerfile is set
# todo: check the dockerfile is change or not
docker_files=($(ls ${DockerRoot}))
echo "original: ${docker_files[@]}" # debug

one_temp="${docker_files[@]}"
sorted_by_version=($(sort_by_version "${one_temp}"))
echo "sorted by version: ${sorted_by_version[@]}" # debug

one_temp="${sorted_by_version[@]}"
two_temp="${stage_order[@]}"
sorted_by_stage=($(sort_by_stage "${one_temp}" "${two_temp}"))
echo "sorted by stage: ${sorted_by_stage[@]}" # debug

# 基于目标stage进行过滤
one_temp="${sorted_by_stage[@]}"
two_temp="${stage_order[@]}"
filter_by_target=($(filter_by_target "${one_temp}" "${two_temp}"))
echo "filter by target stage: ${filter_by_target[@]}" # debug

# 基于目标version进行过滤
one_temp="${filter_by_target[@]}"
two_temp="${TargetVersion}"
filter_by_version=($(filter_by_version "${one_temp}" "${two_temp}"))
echo "filter by target version: ${filter_by_version[@]}" # debug

# 生成镜像name:tag
one_temp="${filter_by_version[@]}"
image_tag=$(generate_tag "${one_temp}" "${UseGit}" "${DockerRoot}")
image_tag=${TargetStage}-${image_tag}
echo "image tag: ${image_tag}" # debug
full_image_name=${ImagePrefix}/${ImageName}:${image_tag}
echo "full image name: ${full_image_name}"

final_target=(${filter_by_version[@]})

# 生成临时整体Dockerfile
temp_dockerfile="$(dirname ${DockerRoot})/.cache/${ImagePrefix}-${ImageName}-${image_tag}.Dockerfile"
$(mkdir -p $(dirname ${temp_dockerfile}); rm ${temp_dockerfile} -f; touch ${temp_dockerfile})
for((i=0;i<${#final_target[@]};i++)){
    echo "write ${DockerRoot}/${final_target[i]} to ${temp_dockerfile}"
    extract_file ${DockerRoot}/${final_target[i]} ${temp_dockerfile}
    #cat ${DockerRoot}/${final_target[i]} >> ${temp_dockerfile}
    echo "
# ${DockerRoot}/${final_target[i]} to ${temp_dockerfile} done" >> ${temp_dockerfile}
}
echo "
#${called}" >> ${temp_dockerfile}

# : 构建镜像
$(DOCKER_BUILDKIT=1 docker build ${BuildOptions} -t ${full_image_name} -f ${temp_dockerfile} ${ExecDir})
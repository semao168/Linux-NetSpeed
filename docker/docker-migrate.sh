#!/bin/bash
# Docker容器迁移工具（Linux版）- 强化文件名含容器名
# 使用：chmod +x docker-migrate.sh && ./docker-migrate.sh

# 定义颜色输出函数
red() { echo -e "\033[31m$1\033[0m"; }
green() { echo -e "\033[32m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }
cyan() { echo -e "\033[36m$1\033[0m"; }

# 检查Docker是否运行
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        red "❌ Docker未启动，请先执行：sudo systemctl start docker"
        read -p "按回车退出..."
        exit 1
    fi
}

# 获取容器列表（Name/ID/Status）并生成序号
get_container_list() {
    echo -e "$(cyan "序号 | 容器名称(Name) | 容器ID(ID)       | 状态(Status)")"
    echo "------------------------------------------------------------------------"
    # 读取容器信息并格式化
    docker ps -a --format "{{.Names}}||{{.ID}}||{{.Status}}" | awk -F'||' '{
        printf "%-4s | %-13s | %-16s | %s\n", NR, $1, substr($2,1,12), $3
    }'
    echo "------------------------------------------------------------------------"
}

# 导出容器（强制包含容器名，核心修复版）
export_container() {
    clear
    cyan "📦 容器导出 - 选择要迁移的容器"
    echo "============================================="
    
    # 显示容器列表
    get_container_list
    
    # 选择容器序号（循环校验，确保输入有效）
    while true; do
        read -p "请输入容器序号：" selected_num
        # 验证序号是否为数字
        if ! [[ "$selected_num" =~ ^[0-9]+$ ]]; then
            red "❌ 输入错误，序号必须为数字"
            continue
        fi
        # 验证序号对应容器是否存在
        cname=$(docker ps -a --format "{{.Names}}" | sed -n "${selected_num}p")
        if [ -n "$cname" ]; then
            break
        else
            red "❌ 序号错误，无对应容器，请重新输入"
        fi
    done
    
    # 强制去空格，避免容器名含特殊字符
    cname=$(echo "$cname" | xargs)
    green "✅ 已选择容器：$cname"
    
    # 生成迁移目录（强制拼接容器名+时间戳）
    timestamp=$(date +%Y%m%d%H%M%S)
    save_dir="docker_migrate_${cname}_${timestamp}"
    mkdir -p "$save_dir"
    
    # 导出镜像（标注容器名）
    yellow "🔹 导出[$cname]镜像..."
    image=$(docker inspect --format "{{.Config.Image}}" "$cname")
    docker save -o "${save_dir}/image.tar" "$image"
    
    # 导出容器配置+写入容器名文件
    yellow "🔹 导出[$cname]容器配置..."
    docker inspect "$cname" > "${save_dir}/config.json"
    echo "$cname" > "${save_dir}/container_name.txt"
    
    # 打包（强制拼接容器名，避免路径问题丢失）
    yellow "🔹 打包[$cname]迁移文件..."
    zip_path="$(pwd)/${save_dir}.tar.gz"
    tar -zcf "$zip_path" "$save_dir"
    rm -rf "$save_dir"
    
    # 输出验证：明确显示带容器名的包路径
    green "✅ 导出成功！"
    green "📦 迁移包：$zip_path"
    green "🔍 包名格式：docker_migrate_<容器名>_<时间戳>.tar.gz"
    read -p "按回车返回主菜单..."
    main_menu
}

# 解析原容器配置（端口/挂载）
parse_original_config() {
    local config_path=$1
    local cname=$2
    
    # 提取镜像
    image=$(jq -r '.Config.Image' "$config_path")
    # 提取重启策略
    restart=$(jq -r '.HostConfig.RestartPolicy.Name' "$config_path")
    [ "$restart" = "null" ] && restart="always"
    
    # 提取端口映射（格式：主机端口:容器端口）
    ports=()
    port_bindings=$(jq -r '.HostConfig.PortBindings | to_entries[] | .key + "||" + .value[0].HostPort' "$config_path" 2>/dev/null)
    while IFS='||' read -r container_port host_port; do
        if [ -n "$host_port" ] && [ "$host_port" != "null" ]; then
            container_port=${container_port%/tcp}
            ports+=("$host_port:$container_port")
        fi
    done <<< "$port_bindings"
    
    # 提取挂载路径（格式：主机路径:容器路径）
    volumes=()
    binds=$(jq -r '.HostConfig.Binds[]' "$config_path" 2>/dev/null)
    while IFS= read -r bind; do
        if [ -n "$bind" ] && [ "$bind" != "null" ]; then
            volumes+=("$bind")
        fi
    done <<< "$binds"
    
    # 提取环境变量
    envs=()
    env_list=$(jq -r '.Config.Env[]' "$config_path" 2>/dev/null)
    while IFS= read -r env; do
        if [ -n "$env" ] && [ "$env" != "null" ]; then
            envs+=("$env")
        fi
    done <<< "$env_list"
}

# 一键恢复原配置启动容器
start_with_original_config() {
    local cname=$1
    clear
    cyan "🔧 一键恢复[$cname]容器配置"
    echo "============================================="
    echo "原容器名称：$cname"
    echo "镜像：$image"
    echo "重启策略：$restart"
    echo "端口映射："
    for port in "${ports[@]}"; do
        echo "  主机端口${port%:*} → 容器端口${port#*:}"
    done
    echo "挂载卷："
    for vol in "${volumes[@]}"; do
        echo "  主机路径${vol%:*} → 容器路径${vol#*:}"
    done
    echo "============================================="
    
    read -p "是否确认按原配置启动[$cname]容器？(Y/N)：" confirm
    if [ "$confirm" = "Y" ] || [ "$confirm" = "y" ]; then
        # 拼接启动命令
        run_cmd="docker run -d --name $cname --restart=$restart"
        
        # 添加端口映射
        for port in "${ports[@]}"; do
            run_cmd+=" -p $port"
        done
        
        # 添加挂载卷（确保主机路径存在）
        for vol in "${volumes[@]}"; do
            host_path=${vol%:*}
            container_path=${vol#*:}
            mkdir -p "$host_path"
            run_cmd+=" -v $vol"
        done
        
        # 添加环境变量
        for env in "${envs[@]}"; do
            run_cmd+=" -e \"$env\""
        done
        
        # 追加镜像名
        run_cmd+=" $image"
        
        # 执行启动命令
        yellow "🔹 执行启动命令：$run_cmd"
        eval "$run_cmd"
        if [ $? -eq 0 ]; then
            green "✅ [$cname]容器启动成功！"
            green "当前容器状态："
            docker ps -f "name=$cname" --format "Name:{{.Names}} Status:{{.Status}} Ports:{{.Ports}}"
        else
            red "❌ [$cname]容器启动失败，请检查命令或配置"
        fi
    else
        yellow "⚠️ 取消[$cname]原配置启动"
    fi
}

# 手动自定义配置启动容器
start_with_custom_config() {
    local default_cname=$1
    local default_image=$2
    clear
    cyan "🔧 手动自定义[$default_cname]容器配置"
    echo "============================================="
    
    # 自定义容器名称
    read -p "输入容器名称（默认：$default_cname）：" new_name
    [ -z "$new_name" ] && new_name=$default_cname
    
    # 自定义端口映射
    read -p "输入端口映射（格式：主机端口:容器端口，多个用空格分隔，如 8080:80 9090:90）：" port_input
    ports=()
    if [ -n "$port_input" ]; then
        for p in $port_input; do
            if [[ "$p" =~ ^[0-9]+:[0-9]+$ ]]; then
                ports+=("$p")
            else
                yellow "⚠️ 端口格式错误：$p，已忽略"
            fi
        done
    fi
    
    # 自定义挂载路径
    read -p "输入挂载卷（格式：主机路径:容器路径，多个用空格分隔，如 /data/memos:/data /var/log:/var/log）：" vol_input
    volumes=()
    if [ -n "$vol_input" ]; then
        for v in $vol_input; do
            if [[ "$v" =~ ^/.+:.+$ ]]; then
                host_path=${v%:*}
                container_path=${v#*:}
                mkdir -p "$host_path"
                volumes+=("$v")
                green "✅ 自动创建主机路径：$host_path"
            else
                yellow "⚠️ 挂载格式错误：$v，已忽略"
            fi
        done
    fi
    
    # 自定义重启策略
    read -p "输入重启策略（always/on-failure/no，默认：always）：" restart
    [ -z "$restart" ] && restart="always"
    
    # 拼接启动命令
    run_cmd="docker run -d --name $new_name --restart=$restart"
    # 添加端口
    for port in "${ports[@]}"; do
        run_cmd+=" -p $port"
    done
    # 添加挂载
    for vol in "${volumes[@]}"; do
        run_cmd+=" -v $vol"
    done
    # 追加镜像
    run_cmd+=" $default_image"
    
    # 确认执行
    echo "============================================="
    yellow "最终启动命令：$run_cmd"
    read -p "是否执行启动？(Y/N)：" confirm
    if [ "$confirm" = "Y" ] || [ "$confirm" = "y" ]; then
        eval "$run_cmd"
        if [ $? -eq 0 ]; then
            green "✅ [$new_name]容器启动成功！"
            docker ps -f "name=$new_name" --format "Name:{{.Names}} Status:{{.Status}} Ports:{{.Ports}}"
        else
            red "❌ [$new_name]容器启动失败"
        fi
    else
        yellow "⚠️ 取消启动"
    fi
}

# 导入容器（兼容含容器名的迁移包）
import_container() {
    clear
    cyan "📥 容器导入工具"
    echo "============================================="
    
    # 输入迁移文件夹路径（支持拖拽/手动输入）
    read -p "输入解压后的迁移文件夹路径：" import_path
    # 标准化路径（去除引号、处理末尾斜杠）
    import_path=$(realpath "${import_path//\"/}")
    
    # 校验路径是否为目录
    if [ ! -d "$import_path" ]; then
        red "❌ 路径不存在或不是文件夹：$import_path"
        read -p "按回车返回..."
        main_menu
    fi
    
    # 优先读取container_name.txt（确保容器名准确）
    name_file="${import_path}/container_name.txt"
    if [ -f "$name_file" ]; then
        cname=$(cat "$name_file")
        green "✅ 从迁移包识别容器名：$cname"
    else
        # 兼容旧版：从文件夹名解析
        dir_name=$(basename "$import_path")
        cname=${dir_name#docker_migrate_}
        cname=${cname%_*}
        yellow "⚠️ 未找到容器名文件，从文件夹名解析：$cname"
    fi
    
    # 导入镜像
    image_tar="${import_path}/image.tar"
    if [ ! -f "$image_tar" ]; then
        red "❌ 未找到image.tar文件：$image_tar"
        read -p "按回车返回..."
        main_menu
    fi
    
    yellow "🔹 导入[$cname]镜像...（路径：$image_tar）"
    docker load -i "$image_tar"
    if [ $? -eq 0 ]; then
        green "✅ [$cname]镜像导入成功！"
    else
        red "❌ [$cname]镜像导入失败"
        read -p "按回车返回..."
        main_menu
    fi
    
    # 导入后配置选择
    echo
    cyan "🔧 [$cname]容器启动配置选择"
    echo "============================================="
    echo "1) 一键恢复原容器配置（端口/挂载/环境变量）"
    echo "2) 手动自定义配置（映射路径/端口）"
    echo "3) 取消启动（仅完成镜像导入）"
    read -p "请选择 [1-3]：" config_choice
    
    # 读取原配置
    config_path="${import_path}/config.json"
    default_image=$(docker images --format "{{.Repository}}:{{.Tag}}" | tail -1)
    if [ -f "$config_path" ]; then
        parse_original_config "$config_path" "$cname"
    fi
    
    case $config_choice in
        1)
            if [ -f "$config_path" ]; then
                start_with_original_config "$cname"
            else
                red "❌ 未找到[$cname]原配置文件，无法一键恢复"
                start_with_custom_config "$cname" "$default_image"
            fi
            ;;
        2)
            start_with_custom_config "$cname" "$default_image"
            ;;
        3)
            yellow "⚠️ 已完成[$cname]镜像导入，未启动容器"
            ;;
        *)
            red "❌ 输入错误，取消启动"
            ;;
    esac
    
    read -p "按回车返回主菜单..."
    main_menu
}

# 主菜单
main_menu() {
    clear
    cyan "============================================="
    cyan "        Docker容器迁移工具（Linux版）"
    cyan "============================================="
    echo "1) 导出容器（打包迁移，文件名含容器名）"
    echo "2) 导入容器（支持一键恢复/自定义配置）"
    echo "3) 退出"
    read -p "请选择操作 [1-3]：" choice
    
    case $choice in
        1) export_container ;;
        2) import_container ;;
        3) exit 0 ;;
        *) 
            red "❌ 输入错误，请重新选择"
            sleep 1
            main_menu
            ;;
    esac
}

# 前置检查（依赖jq）
check_dependency() {
    if ! command -v jq >/dev/null 2>&1; then
        yellow "⚠️ 缺少依赖jq，正在自动安装..."
        if [ -f /etc/debian_version ]; then
            sudo apt update && sudo apt install -y jq
        elif [ -f /etc/redhat-release ]; then
            sudo yum install -y jq
        elif [ -f /etc/arch-release ]; then
            sudo pacman -S --noconfirm jq
        else
            red "❌ 无法自动安装jq，请手动安装后再运行脚本"
            exit 1
        fi
    fi
}

# 启动脚本
check_dependency
check_docker
main_menu
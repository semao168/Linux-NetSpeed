#!/bin/bash

IP=$(curl -s ip.sb)
echo "====================================="
echo "  云服务器端口入口检测 80/443/53"
echo "  公网IP: $IP"
echo "====================================="

check_port() {
    local PORT=$1
    echo -n "端口 $PORT 入口测试: "
    
    # 后台临时监听端口
    nc -l -p $PORT > /dev/null 2>&1 &
    PID=$!
    sleep 1
    
    # 调用外部接口检测是否能通
    RESULT=$(curl -s --max-time 3 "https://portchecker.io/api/v1/check?host=$IP&port=$PORT")
    
    # 杀掉临时监听
    kill $PID > /dev/null 2>&1
    
    if echo "$RESULT" | grep -q '"open":true'; then
        echo -e "\033[32m可访问 ✅\033[0m"
    else
        echo -e "\033[31m不可访问 ❌\033[0m"
    fi
}

check_port 80
check_port 443
check_port 53

echo "====================================="
echo "检测完毕，已关闭临时端口"
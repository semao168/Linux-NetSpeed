#!/bin/bash
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. 系统更新与依赖安装
echo -e "${YELLOW}[1/8] 正在更新系统并安装依赖...${NC}"
apt update -y
apt install -y curl wget unzip openssl socat net-tools

# 2. 安装Xray核心
echo -e "${YELLOW}[2/8] 正在安装Xray核心...${NC}"
bash <(curl -fsSL https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh)

# 3. 生成随机配置参数
echo -e "${YELLOW}[3/8] 正在生成随机配置...${NC}"
UUID=$(cat /proc/sys/kernel/random/uuid)
PORT=$(shuf -i 10000-65535 -n 1)
# 生成Reality密钥对
PRIVATE_KEY=$(xray x25519 | grep "Private key" | awk '{print $3}')
PUBLIC_KEY=$(xray x25519 | grep "Public key" | awk '{print $3}')
SHORT_ID=$(openssl rand -hex 8)

# 4. 获取服务器IP
SERVER_IP=$(curl -s ifconfig.me)

# 5. 生成Xray配置文件（纯IP+VLESS+Reality+XTLS）
echo -e "${YELLOW}[4/8] 正在生成配置文件...${NC}"
cat > /usr/local/etc/xray/config.json << EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "www.google.com:443",
          "xver": 0,
          "serverNames": [
            "www.google.com"
          ],
          "privateKey": "$PRIVATE_KEY",
          "minClientVer": "",
          "maxClientVer": "",
          "maxTimeDiff": 0,
          "shortIds": [
            "$SHORT_ID"
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF

# 6. 配置防火墙（放行端口）
echo -e "${YELLOW}[5/8] 正在配置防火墙...${NC}"
ufw allow $PORT/tcp
ufw reload

# 7. 启动并设置开机自启
echo -e "${YELLOW}[6/8] 正在启动Xray服务...${NC}"
systemctl daemon-reload
systemctl enable xray
systemctl restart xray

# 8. 生成客户端链接
echo -e "${YELLOW}[7/8] 正在生成客户端链接...${NC}"
# VLESS+Reality链接格式：vless://uuid@ip:port?security=reality&encryption=none&alpn=h2&pbk=public_key&fp=chrome&type=tcp&sni=www.google.com&sid=short_id#name
CLIENT_LINK="vless://$UUID@$SERVER_IP:$PORT?security=reality&encryption=none&alpn=h2&pbk=$PUBLIC_KEY&fp=chrome&type=tcp&sni=www.google.com&sid=$SHORT_ID#VLESS-IP-$SERVER_IP"

# 9. 输出配置信息
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}✅ 部署完成！以下是你的节点信息：${NC}"
echo -e "${GREEN}=============================================${NC}"
echo -e "${YELLOW}服务器IP: ${NC}$SERVER_IP"
echo -e "${YELLOW}端口: ${NC}$PORT"
echo -e "${YELLOW}UUID: ${NC}$UUID"
echo -e "${YELLOW}公钥(Public Key): ${NC}$PUBLIC_KEY"
echo -e "${YELLOW}短ID(Short ID): ${NC}$SHORT_ID"
echo -e "${GREEN}=============================================${NC}"
echo -e "${YELLOW}客户端链接(直接复制到V2RayN/Clash等): ${NC}"
echo -e "${GREEN}$CLIENT_LINK${NC}"
echo -e "${GREEN}=============================================${NC}"
echo -e "${YELLOW}服务状态检查命令: ${NC}systemctl status xray"
echo -e "${YELLOW}重启服务命令: ${NC}systemctl restart xray"
echo -e "${GREEN}=============================================${NC}"
# Linux 运维脚本合集

> 适用于 Debian / Ubuntu / CentOS 系统初始化、重装、网络优化、SSH 配置、软件源更换、Grub 修复、LOTServer 管理

---

<!-- 目录 -->
## 目录

- [前提组件](#前提组件)
- [一键 DD CentOS7 国际版](#一键-dd-centos7-国际版)
- [Linux-NetSpeed 网络优化](#linux-netspeed-网络优化)
- [修改 SSH 端口](#修改-ssh-端口)
- [CentOS7 阿里云仓库](#centos7-阿里云仓库)
- [CentOS7 更换仓库](#centos7-更换仓库)
- [Debian9 更换仓库](#debian9-更换仓库)
- [Grub 配置修复](#grub-配置修复)
- [BBR 安装](#bbr-安装)
- [LotServer 加速使用方法](#lotserver-加速使用方法)
- [CentOS7 开机自启](#centos7-开机自启)
- [合集默认密码](#合集默认密码)

---

<!-- 前提组件 -->
## 前提组件

> 执行任何脚本前，请先安装所需依赖组件

### Debian / Ubuntu 系统

```bash
# 安装基础组件
apt-get install -y xz-utils openssl gawk file wget screen

# 创建 screen 会话
screen -S os
```

### RedHat / CentOS 系统

```bash
# 安装基础组件
yum install -y xz openssl gawk file glibc-common wget screen

# 创建 screen 会话
screen -S os
```

---

<!-- 一键 DD -->
## 一键 DD CentOS7 国际版

> 默认密码：`Pwd@CentOS`
> 
> 此脚本用于全自动重装系统为 CentOS7 国际版

```bash
wget --no-check-certificate -O NewReinstall.sh https://raw.githubusercontent.com/fcurrk/reinstall/master/NewReinstall.sh

chmod a+x NewReinstall.sh

bash NewReinstall.sh
```

---

<!-- 网络优化 -->
## Linux-NetSpeed 网络优化

> 用于优化 Linux 服务器网络性能，支持 BBR/BBRplus/LotServer 等加速方案

```bash
# 下载脚本
wget -N --no-check-certificate "https://raw.githubusercontent.com/semao168/Linux-NetSpeed/main/tcp.sh"

# 赋予执行权限
chmod +x tcp.sh

# 运行脚本
./tcp.sh
```

---

<!-- 修改 SSH 端口 -->
## 修改 SSH 端口

> 通过脚本快速修改 SSH 默认端口，增强服务器安全性

```bash
# 安装 wget（如果没有）
yum install wget -y

# 下载 SSH 端口修改脚本
wget -O sshd.sh "https://raw.githubusercontent.com/semao168/lotServer/main/sshd.sh"

# 赋予执行权限
chmod +x sshd.sh

# 运行脚本
./sshd.sh
```

---

<!-- CentOS7 阿里云仓库 -->
## CentOS7 阿里云仓库

> 将 CentOS7 系统源更换为阿里云镜像源，提升软件包下载速度

```bash
# 备份原有源（可选）
# mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

# 下载阿里云源
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
```

---

<!-- CentOS7 更换仓库 -->
## CentOS7 更换仓库

> 将 CentOS7 系统源更换为中科大镜像源，并安装 EPEL 扩展源

```bash
# 备份原有源
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

# 下载中科大源
curl -o /etc/yum.repos.d/CentOS-Base.repo -L https://raw.githubusercontent.com/semao168/Linux-NetSpeed/main/CentOS-ustc.repo

# 安装 EPEL 扩展源
yum install epel-release -y
```

---

<!-- Debian9 更换仓库 -->
## Debian9 更换仓库

> 将 Debian9 系统源更换为国内镜像源

```bash
# 备份原有源
# cp /etc/apt/sources.list /etc/apt/sources.list.backup

# 下载新源
wget -O /etc/apt/sources.list https://raw.githubusercontent.com/semao168/Linux-NetSpeed/main/sources.list --no-check-certificate
```

---

<!-- Grub 配置修复 -->
## Grub 配置修复

> 当系统引导文件丢失时，使用此脚本修复 Grub

### 情况一：/boot/grub/grub.conf 缺失

```bash
# 安装 grub
yum install -y grub

# 重新生成 grub 配置文件
grub-mkconfig -o /boot/grub/grub.conf
```

### 情况二：/boot/grub2/grub.cfg 缺失

```bash
# 安装 grub2
yum install -y grub2

# 重新生成 grub 配置文件
grub2-mkconfig -o /boot/grub2/grub.cfg
```

---

<!-- BBR 安装 -->
## BBR 安装

> 安装并启用 BBR 拥塞控制算法，提升网络吞吐量

```bash
# 下载 BBR 安装脚本
wget -N --no-check-certificate "https://raw.githubusercontent.com/semao168/Linux-NetSpeed/main/bbr.sh"

# 赋予执行权限
chmod +x bbr.sh

# 运行脚本
./bbr.sh
```

### 验证 BBR 是否启用成功

```bash
# 查看当前使用的拥塞控制算法
sysctl net.ipv4.tcp_congestion_control

# 预期返回值：
# net.ipv4.tcp_congestion_control = bbr
```

---

<!-- LotServer 加速 -->
## LotServer 加速使用方法

> LotServer（锐速）是一款 TCP 加速软件，可显著提升服务器网络性能

| 操作 | 命令 |
|------|------|
| 启动 | `/appex/bin/lotServer.sh start` |
| 停止 | `/appex/bin/lotServer.sh stop` |
| 查看状态 | `/appex/bin/lotServer.sh status` |
| 重启 | `/appex/bin/lotServer.sh restart` |

---

<!-- CentOS7 开机自启 -->
## CentOS7 开机自启

> 设置 LotServer 开机自动启动

```bash
# 将启动命令写入启动文件
echo "/appex/bin/lotServer.sh restart" >> /etc/rc.d/rc.local

# 赋予执行权限
chmod +x /etc/rc.d/rc.local
```

---

<!-- 合集默认密码 -->
## 合集默认密码

> 以下为各系统镜像的默认登录密码，请及时修改

### Linux 系统

| 系统版本 | 默认密码 |
|----------|----------|
| CentOS 7.7（已关闭防火墙及 SELinux） | `Pwd@CentOS` |
| CentOS 7 | `cxthhhhh.com` |
| CentOS 7 (ARM64 / UEFI) | `cxthhhhh.com` |
| CentOS 8 | `cxthhhhh.com` |
| Rocky 8 | `cxthhhhh.com` |
| Rocky 8 (UEFI) | `cxthhhhh.com` |
| Rocky 8 (ARM64 / UEFI) | `cxthhhhh.com` |
| CentOS 9 | `cxthhhhh.com` |
| CentOS 6 | `Minijer.com` |
| Debian 11 | `Minijer.com` |
| Debian 10 | `Minijer.com` |
| Debian 9 | `Minijer.com` |
| Debian 8 | `Minijer.com` |
| Ubuntu 20.04 | `Minijer.com` |
| Ubuntu 18.04 | `Minijer.com` |
| Ubuntu 16.04 | `Minijer.com` |

### Windows 系统

| 系统版本 | 默认密码 |
|----------|----------|
| Windows Server 2022 | `cxthhhhh.com` |
| Windows Server 2022 (UEFI) | `cxthhhhh.com` |
| Windows Server 2019 | `cxthhhhh.com` |
| Windows Server 2016 | `cxthhhhh.com` |
| Windows Server 2012 | `cxthhhhh.com` |
| Windows Server 2008 | `cxthhhhh.com` |
| Windows Server 2003 | `cxthhhhh.com` |
| Windows 10 LTSC | `Teddysun.com` |
| Windows 10 LTSC (UEFI) | `Teddysun.com` |
| Windows 7 x86 Lite | `nat.ee` |
| Windows 7 x86 Lite（阿里云专用） | `nat.ee` |
| Windows 7 x64 Lite | `nat.ee` |
| Windows 7 x64 Lite (UEFI) | `nat.ee` |
| Windows 10 LTSC Lite | `nat.ee` |
| Windows 10 LTSC Lite（阿里云专用） | `nat.ee` |
| Windows 10 LTSC Lite (UEFI) | `nat.ee` |
| Windows Server 2003 Lite | `WinSrv2003x86-Chinese`（C 盘默认 10G） |
| Windows Server 2008 Lite | `nat.ee` |
| Windows Server 2008 Lite (UEFI) | `nat.ee` |
| Windows Server 2012 Lite | `nat.ee` |
| Windows Server 2012 Lite (UEFI) | `nat.ee` |
| Windows Server 2016 Lite | `nat.ee` |
| Windows Server 2016 Lite (UEFI) | `nat.ee` |
| Windows Server 2022 Lite | `nat.ee` |
| Windows Server 2022 Lite (UEFI) | `nat.ee` |

---

<!-- 自定义镜像 -->
## 自定义镜像

> 更多自定义镜像需求可自行扩展

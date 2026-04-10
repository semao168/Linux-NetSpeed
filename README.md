Linux 运维脚本合集
适用于 Debian/Ubuntu/CentOS 系统初始化、重装、网络优化、SSH 配置、软件源更换、Grub 修复、LotServer 管理
前提组件
Debian/Ubuntu
bash
运行
apt-get install -y xz-utils openssl gawk file wget screen && screen -S os
RedHat/CentOS
bash
运行
yum install -y xz openssl gawk file glibc-common wget screen && screen -S os
一键 DD CentOS7 国际版
默认密码：Pwd@CentOS
bash
运行
wget --no-check-certificate -O NewReinstall.sh https://raw.githubusercontent.com/fcurrk/reinstall/master/NewReinstall.sh && chmod a+x NewReinstall.sh && bash NewReinstall.sh
Linux-NetSpeed 网络优化
bash
运行
wget -N --no-check-certificate "https://raw.githubusercontent.com/semao168/Linux-NetSpeed/main/tcp.sh"
chmod +x tcp.sh
./tcp.sh
修改 SSH 端口
bash
运行
yum install wget -y && wget -O sshd.sh "https://raw.githubusercontent.com/semao168/lotServer/main/sshd.sh" && chmod +x sshd.sh && ./sshd.sh
CentOS7 阿里云仓库
bash
运行
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
CentOS7 更换仓库
bash
运行
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
curl -o /etc/yum.repos.d/CentOS-Base.repo -L https://raw.githubusercontent.com/semao168/Linux-NetSpeed/main/CentOS-ustc.repo
yum install epel-release -y
Debian9 更换仓库
bash
运行
wget -O /etc/apt/sources.list https://raw.githubusercontent.com/semao168/Linux-NetSpeed/main/sources.list --no-check-certificate
Grub 配置修复
/boot/grub/grub.conf 缺失
bash
运行
yum install -y grub
grub-mkconfig -o /boot/grub/grub.conf
/boot/grub2/grub.cfg 缺失
bash
运行
yum install -y grub2
grub2-mkconfig -o /boot/grub2/grub.cfg
BBR 安装
bash
运行
wget -N --no-check-certificate "https://raw.githubusercontent.com/semao168/Linux-NetSpeed/main/bbr.sh"
chmod +x bbr.sh
./bbr.sh
验证 BBR
bash
运行
sysctl net.ipv4.tcp_congestion_control
返回 net.ipv4.tcp_congestion_control = bbr 即为成功
LotServer 加速使用方法
启动：/appex/bin/lotServer.sh start
停止：/appex/bin/lotServer.sh stop
状态：/appex/bin/lotServer.sh status
重启：/appex/bin/lotServer.sh restart
CentOS7 开机自启
bash
运行
echo "/appex/bin/lotServer.sh restart" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
41 合 1 系统默认密码
CentOS 7.7：Pwd@CentOS（已关闭防火墙及 SELinux）
CentOS 7：cxthhhhh.com
CentOS 7 (ARM64、UEFI)：cxthhhhh.com
CentOS 8：cxthhhhh.com
Rocky 8：cxthhhhh.com
Rocky 8 (UEFI)：cxthhhhh.com
Rocky 8 (ARM64、UEFI)：cxthhhhh.com
CentOS 9：cxthhhhh.com
CentOS 6：Minijer.com（官方源原版）
Debian 11：Minijer.com（官方源原版）
Debian 10：Minijer.com（官方源原版）
Debian 9：Minijer.com（官方源原版）
Debian 8：Minijer.com（官方源原版）
Ubuntu 20.04：Minijer.com（官方源原版）
Ubuntu 18.04：Minijer.com（官方源原版）
Ubuntu 16.04：Minijer.com（官方源原版）
Windows Server 2022：cxthhhhh.com
Windows Server 2022 (UEFI)：cxthhhhh.com
Windows Server 2019：cxthhhhh.com
Windows Server 2016：cxthhhhh.com
Windows Server 2012：cxthhhhh.com
Windows Server 2008：cxthhhhh.com
Windows Server 2003：cxthhhhh.com
Windows 10 LTSC：Teddysun.com
Windows 10 LTSC (UEFI)：Teddysun.com
Windows 7 x86 Lite：nat.ee
Windows 7 x86 Lite（阿里云专用）：nat.ee
Windows 7 x64 Lite：nat.ee
Windows 7 x64 Lite (UEFI)：nat.ee
Windows 10 LTSC Lite：nat.ee
Windows 10 LTSC Lite（阿里云专用）：nat.ee
Windows 10 LTSC Lite (UEFI)：nat.ee
Windows Server 2003 Lite：WinSrv2003x86-Chinese（C 盘默认 10G）
Windows Server 2008 Lite：nat.ee
Windows Server 2008 Lite (UEFI)：nat.ee
Windows Server 2012 Lite：nat.ee
Windows Server 2012 Lite (UEFI)：nat.ee
Windows Server 2016 Lite：nat.ee
Windows Server 2016 Lite (UEFI)：nat.ee
Windows Server 2022 Lite：nat.ee
Windows Server 2022 Lite (UEFI)：nat.ee
自定义镜像
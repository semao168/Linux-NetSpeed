# 一键DD Centos7 国际 默认密码：Pwd@CentOS
```
wget --no-check-certificate -O AutoReinstall.sh https://git.io/AutoReinstall.sh && bash AutoReinstall.sh
```
# 一键DD Centos7国内可用版 默认密码：Pwd@CentOS
```
bash <(wget --no-check-certificate -qO- https://cdn.jsdelivr.net/gh/hiCasper/Shell@master/AutoReinstall.sh)
```
```
wget --no-check-certificate -O NewReinstall.sh https://git.io/newbetags && chmod a+x NewReinstall.sh && bash NewReinstall.sh
```
如为CN主机(部分主机商已不能使用)，可能出现报错或不能下载脚本的问题，可执行以下命令开始安装.
```
wget --no-check-certificate -O NewReinstall.sh https://cdn.jsdelivr.net/gh/fcurrk/reinstall@master/NewReinstall.sh && chmod a+x NewReinstall.sh 
```



# Linux-NetSpeed
```
wget -N --no-check-certificate "https://raw.githubusercontent.com/semao168/Linux-NetSpeed/main/tcp.sh"
chmod +x tcp.sh
./tcp.sh
```


 > 修改SSH端口
```
yum install wget -y && wget -O sshd.sh "https://raw.githubusercontent.com/semao168/lotServer/main/sshd.sh" && chmod +x sshd.sh && ./sshd.sh
```
 > centos7阿里云仓库
```
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
```
 > centos7更换仓库
```
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup


curl -o /etc/yum.repos.d/CentOS-Base.repo  -L https://raw.githubusercontent.com/semao168/Linux-NetSpeed/main/CentOS-ustc.repo

yum install epel-release -y


#/boot/grub/grub.conf 缺失：
 
yum install -y grub
grub-mkconfig -o /boot/grub/grub.conf
 
#/boot/grub2/grub.cfg 缺失：
 
yum install -y grub2
grub2-mkconfig -o /boot/grub2/grub.cfg

```


 > debian9更换仓库
```

wget -O  /etc/apt/sources.list  https://raw.githubusercontent.com/semao168/Linux-NetSpeed/main/sources.list --no-check-certificate


```


```
wget -N --no-check-certificate "https://raw.githubusercontent.com/semao168/Linux-NetSpeed/main/bbr.sh"
chmod +x bbr.sh
./bbr.sh
```
sysctl net.ipv4.tcp_congestion_control

如果得到如下结果则代表BBR安装成功：

net.ipv4.tcp_congestion_control = bbr



***
***
## 使用方法
- 启动命令 /appex/bin/lotServer.sh start
- 停止加速 /appex/bin/lotServer.sh stop
- 状态查询 /appex/bin/lotServer.sh status
- 重新启动 /appex/bin/lotServer.sh restart

***
***
## Centos 7开机启动
```
echo "/appex/bin/lotServer.sh restart" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
```

## 41合1系统密码：
1、CentOS 7.7 (已关闭防火墙及SELinux，默认密码Pwd@CentOS)
2、CentOS 7 (默认密码cxthhhhh.com)
3、CentOS 7 (支持ARM64、UEFI，默认密码cxthhhhh.com)
4、CentOS 8 (默认密码cxthhhhh.com)
5、Rocky 8 (默认密码cxthhhhh.com)
6、Rocky 8 (支持UEFI，默认密码cxthhhhh.com)
7、Rocky 8 (支持ARM64、UEFI，默认密码cxthhhhh.com)
8、CentOS 9 (默认密码cxthhhhh.com)
9、CentOS 6 (官方源原版，默认密码Minijer.com)
10、Debian 11 (官方源原版，默认密码Minijer.com)
11、Debian 10 (官方源原版，默认密码Minijer.com)
12、Debian 9 (官方源原版，默认密码Minijer.com)
13、Debian 8 (官方源原版，默认密码Minijer.com)
14、Ubuntu 20.04 (官方源原版，默认密码Minijer.com)
15、Ubuntu 18.04 (官方源原版，默认密码Minijer.com)
16、Ubuntu 16.04 (官方源原版，默认密码Minijer.com)
17、Windows Server 2022 (默认密码cxthhhhh.com)
18、Windows Server 2022 (支持UEFI，默认密码cxthhhhh.com)
19、Windows Server 2019 (默认密码cxthhhhh.com)
20、Windows Server 2016 (默认密码cxthhhhh.com)
21、Windows Server 2012 (默认密码cxthhhhh.com)
22、Windows Server 2008 (默认密码cxthhhhh.com)
23、Windows Server 2003 (默认密码cxthhhhh.com)
24、Windows 10 LTSC (默认密码Teddysun.com)
25、Windows 10 LTSC (支持UEFI，默认密码Teddysun.com)
26、Windows 7 x86 Lite (默认密码nat.ee)
27、Windows 7 x86 Lite (阿里云专用，默认密码nat.ee)
28、Windows 7 x64 Lite (默认密码nat.ee)
29、Windows 7 x64 Lite (支持UEFI，默认密码nat.ee)
30、Windows 10 LTSC Lite (默认密码nat.ee)
31、Windows 10 LTSC Lite (阿里云专用，默认密码nat.ee)
32、Windows 10 LTSC Lite (支持UEFI，默认密码nat.ee)
33、Windows Server 2003 Lite (C盘默认10G，默认密码WinSrv2003x86-Chinese)
34、Windows Server 2008 Lite (默认密码nat.ee)
35、Windows Server 2008 Lite (支持UEFI，默认密码nat.ee)
36、Windows Server 2012 Lite (默认密码nat.ee)
37、Windows Server 2012 Lite (支持UEFI，默认密码nat.ee)
38、Windows Server 2016 Lite (默认密码nat.ee)
39、Windows Server 2016 Lite (支持UEFI，默认密码nat.ee)
40、Windows Server 2022 Lite (默认密码nat.ee)
41、Windows Server 2022 Lite (支持UEFI，默认密码nat.ee)
99、自定义镜像
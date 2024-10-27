# 一键DD Centos7 国际 默认密码：Pwd@CentOS
```
wget --no-check-certificate -O AutoReinstall.sh https://git.io/AutoReinstall.sh && bash AutoReinstall.sh
```
# 一键DD Centos7国内可用版 默认密码：Pwd@CentOS
```
bash <(wget --no-check-certificate -qO- https://cdn.jsdelivr.net/gh/hiCasper/Shell@master/AutoReinstall.sh)

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
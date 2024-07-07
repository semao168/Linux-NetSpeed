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

 > centos7更换仓库
```
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

curl -o /etc/yum.repos.d/CentOS-Base.repo  -L https://raw.githubusercontent.com/semao168/Linux-NetSpeed/main/CentOS-ustc.repo

yum install epel-release -y
```

 > debian9更换仓库
```

curl -o /etc/apt/sources.list  -L https://raw.githubusercontent.com/semao168/Linux-NetSpeed/main/sources.list

yum install epel-release -y
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
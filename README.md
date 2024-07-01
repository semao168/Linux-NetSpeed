# Linux-NetSpeed
```
wget -N --no-check-certificate "https://raw.githubusercontent.com/semao168/Linux-NetSpeed/main/tcp.sh"
chmod +x tcp.sh
./tcp.sh
```




```
wget -N --no-check-certificate "https://raw.githubusercontent.com/semao168/Linux-NetSpeed/main/bbr.sh"
chmod +x bbr.sh
./bbr.sh
```

 > 修改SSH端口
```
yum install wget -y && wget -O sshd.sh "https://raw.githubusercontent.com/semao168/lotServer/main/sshd.sh" && chmod +x sshd.sh && ./sshd.sh
```

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
echo "/usr/bin/sh /appex/bin/lotServer.sh restart" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
```
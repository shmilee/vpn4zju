信息中心VPN接入
===============

* `A`: [客户端下载页面][1]
* `B`: [紫金港新客户端][2]
* `C`: [其他校区windows][3]
* `D`: [其他校区linux][4]

部分配置文件
------------

* `DoubleLineRouteMgr.ini` in `B`/`ZJU.exe`

```
[FirstLineRouteTable]
;gateway=
;mask=
;0=
;mask0=
0=10.0.0.0/8
1=210.32.0.0/20
2=222.205.0.0/17
3=210.32.128.0/19
4=210.32.160.0/21
5=210.32.168.0/22
6=210.32.172.0/23
7=210.32.174.0/24
8=210.32.176.0/20
9=58.196.192.0/19
10=58.196.224.0/20

[SecondLineRouteTable]
;mask=
;0=
;mask0=
```


* `runinfo.ini` in `C`

```
[services]
ServiceCount=3
ServiceLable1=10元包月
ServiceCode1=a
ServiceLable2=30元包月
ServiceCode2=c
ServiceLable3=50元包月
ServiceCode3=d

[L2tpServer]
L2tpServerCount=4
L2tpServerAddress1=lns.zju.edu.cn
L2tpServerAddress2=10.5.1.9
L2tpServerAddress3=10.5.1.7
L2tpServerAddress4=10.5.1.5

[RouteTable]
RouteTableCount=10
RouteTableDest1=10.0.0.0
RouteTableMask1=255.0.0.0
RouteTableDest2=210.32.0.0
RouteTableMask2=255.255.240.0
RouteTableDest3=222.205.0.0
RouteTableMask3=255.255.128.0
RouteTableDest4=210.32.128.0
RouteTableMask4=255.255.224.0
RouteTableDest5=210.32.160.0
RouteTableMask5=255.255.248.0
RouteTableDest6=210.32.168.0
RouteTableMask6=255.255.252.0
RouteTableDest7=210.32.172.0
RouteTableMask7=255.255.254.0
RouteTableDest8=210.32.176.0
RouteTableMask8=255.255.240.0
RouteTableDest9=58.196.192.0
RouteTableMask9=255.255.224.0
RouteTableDest10=58.196.224.0
RouteTableMask10=255.255.240.0
```

* `浙江大学L2TP Linux客户端配置手册.doc` in `D`

配置/etc/xl2tpd/xl2tpd.conf
```
#vi /etc/xl2tpd/xl2tpd.conf
[lac ZJU_VPN]
lns=IP_OR_DOMAIN_ADDRESS_OF_BRAS_SERVER
redial=yes
redial timeout=15
max redials=5
require pap=no
require chap=yes
require authentication=yes
name=USER_NAME@SERVICE_TYPE
ppp debug=no
pppoptfile = /etc/ppp/options.xl2tpd.zju
```

> 说明：IP_OR_DOMAIN_ADDRESS_OF_BRAS_SERVER是`10.5.1.7`或者`10.5.1.9`，两个选任意一个；  
> USER_NAME@SERVICE_TYPE的USER_NAME是您的用户名，SERVICE_TYPE是您所使用域。

创建options.xl2tpd.zju
```
#vi /etc/ppp/options.xl2tpd.zju
noauth
proxyarp
defaultroute
```

保存用户名和密码
```
#vi /etc/ppp/chap-secrets
USER_NAME@SERVICE_TYPE		*	“USER_PASSWORD”	*
```

> 说明：USER_NAME@SERVICE_TYPE的USER_NAME是您的用户名，SERVICE_TYPE是您所使用域；USER_PASSWORD是您的帐户密码；

连接
```
1.启动服务
#service xl2tpd start
2.连接Bras
# echo 'c ZJU_VPN' > /var/run/xl2tpd/l2tp-control
3.修改路由
a)route add -host $VPN_SERV gw $DEF_GW metric 1 dev eth0
b)route add –net target netmask NM gw $DEF_GW metric 1 dev eth0
c)route del –net default gw $DEF_GW
d)route add –net default gw $VPN_GW metric 1 dev ppp0
```
> 说明：在配置路由之前请使用`ifconfig`命令查看PPP0的接口地址，并记录下来；  
> $VPN_SERV是10.5.1.7或`10.5.1.9`，要求跟前面“配置L2TP”中第一条中IP_OR_DOMAIN_ADDRESS_OF_BRAS_SERVER保持一致；  
> $DEF_GW是本地IP地址的网关，一般是`10.*.*.*`的地址；  
> $VPN_GW是通过`ifconfig`命令查看PPP0的接口地址；一般是`172.16.*.*`或者`210.32.*.*`或者`222.205.*.*`;

断开
```
1、删除路由
a)route del –net default gw $VPN_GW
b)route add –net default gw $DEF_GW
c)route del -host $VPN_SERV gw $DEF_GW
d)...

2、断开Bras
# echo 'd vipedu' > /var/run/xl2tpd/l2tp-control

3、关闭服务
#service xl2tpd stop
```


About subnet masks
==================

* [网页][5]

* a table
```
Mask value:                             # of
Hex            CIDR   Decimal           addresses  Classfull
80.00.00.00    /1     128.0.0.0         2048 M     128 A
C0.00.00.00    /2     192.0.0.0         1024 M      64 A
E0.00.00.00    /3     224.0.0.0          512 M      32 A
F0.00.00.00    /4     240.0.0.0          256 M      16 A
F8.00.00.00    /5     248.0.0.0          128 M       8 A
FC.00.00.00    /6     252.0.0.0           64 M       4 A
FE.00.00.00    /7     254.0.0.0           32 M       2 A
FF.00.00.00    /8     255.0.0.0           16 M       1 A
FF.80.00.00    /9     255.128.0.0          8 M     128 B
FF.C0.00.00   /10     255.192.0.0          4 M      64 B
FF.E0.00.00   /11     255.224.0.0          2 M      32 B
FF.F0.00.00   /12     255.240.0.0       1024 K      16 B
FF.F8.00.00   /13     255.248.0.0        512 K       8 B
FF.FC.00.00   /14     255.252.0.0        256 K       4 B
FF.FE.00.00   /15     255.254.0.0        128 K       2 B
FF.FF.00.00   /16     255.255.0.0         64 K       1 B
FF.FF.80.00   /17     255.255.128.0       32 K     128 C
FF.FF.C0.00   /18     255.255.192.0       16 K      64 C
FF.FF.E0.00   /19     255.255.224.0        8 K      32 C
FF.FF.F0.00   /20     255.255.240.0        4 K      16 C
FF.FF.F8.00   /21     255.255.248.0        2 K       8 C
FF.FF.FC.00   /22     255.255.252.0        1 K       4 C
FF.FF.FE.00   /23     255.255.254.0      512         2 C
FF.FF.FF.00   /24     255.255.255.0      256         1 C
FF.FF.FF.80   /25     255.255.255.128    128       1/2 C
FF.FF.FF.C0   /26     255.255.255.192     64       1/4 C
FF.FF.FF.E0   /27     255.255.255.224     32       1/8 C
FF.FF.FF.F0   /28     255.255.255.240     16      1/16 C
FF.FF.FF.F8   /29     255.255.255.248      8      1/32 C
FF.FF.FF.FC   /30     255.255.255.252      4      1/64 C
FF.FF.FF.FE   /31     255.255.255.254      2     1/128 C
FF.FF.FF.FF   /32     255.255.255.255   This is a single host route
```


[1]:http://networking.zju.edu.cn/redir.php?catalog_id=4582
[2]:http://zuits.zju.edu.cn/wescms/sys/filebrowser/file.php?cmd=download&id=195521
[3]:http://zuits.zju.edu.cn/wescms/sys/filebrowser/file.php?cmd=download&id=149412
[4]:http://zuits.zju.edu.cn/wescms/sys/filebrowser/file.php?cmd=download&id=13532
[5]:http://www.akadia.com/services/ip_routing_on_subnets.html

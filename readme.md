使用帮助
========

1. 依赖 xl2tpd iproute，之前安装过的 ZJUvpn 包最好先删除。

2. 安装完成后，首先运行 `vpn4zju -cfg` 配置VPN帐号。

3. 连接请运行 `systemctl start vpn4zju.service`;  
   直接运行脚本，需手动处理 xl2ptd 服务。

4. 开机自动连接。  
   为了确保在连内网之后再拨VPN，需要添加依赖到文件  
   `/etc/systemd/system/vpn4zju.service.d/customdependency.conf`
    ```
    [Unit]
    Requires=new dependency
    After=new dependency
    ```
   具体请根据网络环境填写， [一个参考][1]。  
   举例：`systemd-networkd` 处理固定IP就写`systemd-networkd-wait-online.service`。  

   最后 `systemctl enable vpn4zju`。

5. 日志查看， `journalctl -u vpn4zju` and `journalctl -u xl2tpd`.

6. 默认 `PPP device` 是 `ppp0` 或 `ppp1`, 如果系统中 `ppp` 打过布丁
   [pppd: allow use of arbitrary interface names ](https://github.com/paulusmack/ppp/commit/bbcdc4366bbee6c3f4e1ddda31e4eec8c1b3ccc2)
   可修改 `/etc/ppp/options.xl2tpd.zju`, 设置 `ifname`.
   如设置 `ifname zjuvpn` 之后 `PPP device` 就变成 `zjuvpn`.
   ```bash
   [$] sudo vpn4zju -c
   [MSG] Trying to bring up VPN... 1 secs... Done!
   [MSG] Detected gateway: 10.12.74.1, PPP device: zjuvpn
   [MSG] Setting up route table...  Done!   
   ```

7. python 脚本 `zjuwlan`, 用于登录无线. `zjuwlan -h` 查看使用帮助.
   依赖 `keyring` 存用户名、密码, `requests` 发送请求.
   配合 `wicd` 可在连接无线后自动登录.

参考致谢
========

* http://www.cc98.org/dispbbs.asp?boardID=212&ID=2148145
* http://www.cc98.org/dispbbs.asp?boardID=212&ID=3760618
* http://www.cc98.org/dispbbs.asp?boardID=212&ID=4061136
* ./info.md

[1]:http://www.freedesktop.org/wiki/Software/systemd/NetworkTarget/

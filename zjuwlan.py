#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2019 shmilee

import argparse
import getpass
import keyring
import requests

username = keyring.get_password('zjuvpn', 'username')
password = keyring.get_password('zjuvpn', 'password')

post_url = 'https://net.zju.edu.cn/include/auth_action.php'
post_headers = {
    'Host': 'net.zju.edu.cn',
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0',
    'Referer': 'https://net.zju.edu.cn/srun_portal_pc.php?url=&ac_id=3',
    'Content-Type': 'application/x-www-form-urlencoded',
    'X-Requested-With': 'XMLHttpRequest',
    # 'Cookie': 'login=xxx'
}
post_login_data = dict(
    action='login',
    username=username,
    password=password,
    ac_id=3,
    # user_ip='',
    # nas_ip='',
    # user_mac='',
    save_me=0,
    ajax=1,
)
post_logout_data = dict(
    action='logout',
    username=username,
    password=password,
    ajax=1,
)


def main(args):
    if args.action == 'conf':
        username = getpass.getpass("Username in 'zjuvpn': ")
        password = getpass.getpass(
            "Password for '%s' in 'zjuvpn': " % username)
        keyring.set_password("zjuvpn", "username", username)
        keyring.set_password("zjuvpn", "password", password)
        print("Done.")
    elif args.action == 'login':
        print('Logging in ZJUWLAN ...')
        response = requests.post(
            post_url, data=post_login_data, headers=post_headers)
        response.encoding = 'utf-8'
        if response.text.startswith('login_ok'):
            print('Login successful.')
        else:
            print(response.text)
    elif args.action == 'logout':
        print('Logging out ZJUWLAN ...')
        response = requests.post(
            post_url, data=post_logout_data, headers=post_headers)
        response.encoding = 'utf-8'
        if response.text.startswith('网络已断开'):
            print('Logout successful.')
        else:
            print(response.text)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Login/Logout ZJUWLAN v0.1 by shmilee@zju.edu.cn",
        formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('action', metavar='Action',
                        nargs='?', default='login',
                        choices=['login', 'logout', 'conf'],
                        help='%(choices)s\n'
                             'default is %(default)s\n'
                             'conf: set username password')
    args = parser.parse_args()
    main(args)

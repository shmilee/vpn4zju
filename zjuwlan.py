#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (c) 2019 shmilee

import os
import sys
import time
import argparse
import configparser
import getpass
import keyring
import requests

post_url = 'https://net.zju.edu.cn/include/auth_action.php'
post_headers = {
    'Host': 'net.zju.edu.cn',
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:66.0) Gecko/20100101 Firefox/66.0',
    'Referer': 'https://net.zju.edu.cn/srun_portal_pc.php?url=&ac_id=3',
    'Content-Type': 'application/x-www-form-urlencoded',
    'X-Requested-With': 'XMLHttpRequest',
    # 'Cookie': 'login=xxx'
}


def get_v_user_pass():
    xl2tpdconf = '/etc/xl2tpd/xl2tpd.conf'
    username, password = None, None
    try:
        print("Use 'username', 'password' from %s ..." % xl2tpdconf)
        config = configparser.ConfigParser(inline_comment_prefixes=('#', ';'))
        config.read(xl2tpdconf)
        auth_file = config['global']['auth file']
        username = config['lac ZJU']['name']
        if username.find('@'):
            username = username[:username.find('@')]
    except (Exception, KeyError) as e:
        print(e)
    if not username:
        print("Failed to get ['lac ZJU']['name'] in %s!" % xl2tpdconf)
    else:
        try:
            with open(auth_file) as auth:
                for line in auth.readlines():
                    if line.startswith(username):
                        password = line[line.find('*')+1:line.rfind('*')]
                        password = password.strip()
        except (Exception, KeyError) as e:
            print(e)
        if not password:
            print("Failed to get 'password' in %s!" % auth_file)
    return username, password


def get_k_user_pass():
    username, password = None, None
    try:
        print("Use 'username', 'password' from keyring ...")
        username = keyring.get_password('zjuvpn', 'username')
        password = keyring.get_password('zjuvpn', 'password')
    except (Exception, RuntimeError) as e:
        print(e)
    if not username:
        print("Failed to get 'username' by keyring!")
    if not password:
        print("Failed to get 'password' by keyring!")
    return username, password


def get_post_response(action):
    if getpass.getuser() == 'root':
        username, password = get_v_user_pass()
    else:
        username, password = get_k_user_pass()
    if not(username and password):
        sys.exit(1)
    if action == 'login':
        post_data = dict(
            action='login',
            username=username,
            password=password,
            ac_id=3,
            # user_ip='',
            # nas_ip='',
            # user_mac='',
            save_me=0,
            ajax=1)
    elif action == 'logout':
        post_data = dict(
            action='logout',
            username=username,
            password=password,
            ajax=1)
    response = requests.post(
        post_url, data=post_data, headers=post_headers)
    response.encoding = 'utf-8'
    return response


def main(args):
    if args.action == 'kconf':
        username = input("Username in 'zjuvpn': ")
        password = getpass.getpass(
            "Password for '%s' in 'zjuvpn': " % username)
        keyring.set_password("zjuvpn", "username", username)
        keyring.set_password("zjuvpn", "password", password)
        print("Done.")
    elif args.action == 'vconf':
        os.system('sudo vpn4zju -cfg')
    elif args.action == 'login':
        print('Logging in ZJUWLAN ...')
        response = get_post_response('login')
        if response.text.startswith('E2532:'):
            print(response.text)
            # The two authentication interval cannot be less than 10 seconds.
            for i in range(1,11):
                print('Login after %d seconds.' % i, end='\r')
                time.sleep(1)
            response = get_post_response('login')
        if response.text.startswith('login_ok'):
            print('Login successful.')
        else:
            print(response.text)
    elif args.action == 'logout':
        print('Logging out ZJUWLAN ...')
        response = get_post_response('logout')
        if response.text.startswith('网络已断开'):
            print('Logout successful.')
        else:
            print(response.text)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Login/Logout ZJUWLAN v2.0 by shmilee@zju.edu.cn",
        epilog="Password stored by keyring is used for current USER,\n"
        "and stored by vpn4zju(ppp) is used for root USER.",
        formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('action', metavar='Action',
                        nargs='?', default='login',
                        choices=['login', 'logout', 'kconf', 'vconf'],
                        help='%(choices)s\n'
                             'default is %(default)s\n'
                             'kconf: set username password by keyring\n'
                             'vconf: set username password by vpn4zju')
    args = parser.parse_args()
    main(args)

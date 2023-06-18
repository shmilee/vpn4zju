#!/bin/bash
# Copyright (C) 2023 shmilee

# Two default, when both Ethernet and Wireless are connected.
#
# ip r list
# default via 10.xx.yy.1 dev wlan0 proto dhcp src 10.xx.jj.ii metric 600 
# default via 10.mm.nn.1 dev eth0 proto static metric 20100 
# 10.mm.nn.0/24 dev eth0 proto kernel scope link src 10.mm.nn.kk metric 100 
# 10.xx.yy.0/17 dev wlan0 proto kernel scope link src 10.xx.jj.ii metric 600 
#

my_route_table=('10.0.0.0/8'
    '58.196.192.0/19'
    '58.196.224.0/20'
    '210.32.0.0/20'
    '210.32.128.0/19'
    '210.32.160.0/21'
    '210.32.168.0/22'
    '210.32.172.0/23'
    '210.32.176.0/20'
    '222.205.0.0/17'
)

# $1 my-IF; $2 my-GW; $3 default-IF; $4 default-GW
set_my_route() {
    local IFNAME=${1:-eth0}
    local IFGW=${2:-$(ip r | grep 'via.*eth0' | awk '{print $3}')}
    local default_IFNAME=${3:-$(ip r | grep 'default via' | grep -v $IFNAME | awk '{print $5}')}
    local default_IFGW=${4:-$(ip r | grep 'default via' | grep -v $IFNAME | awk '{print $3}')}
    for rt in ${my_route_table[@]}; do
        echo "Add new route: $rt via $IFGW dev $IFNAME"
        ip route add $rt via $IFGW dev $IFNAME
    done
    echo "Delete default route: default via $IFGW dev $IFNAME"
    ip route del default via $IFGW dev $IFNAME
    echo "Select default route: default via $default_IFGW dev $default_IFNAME"
}

# $1 my-IF; $2 my-GW;
reset_my_route() {
    local IFNAME=${1:-eth0}
    local IFGW=${2:-$(ip r | grep 'via.*eth0' | awk '{print $3}' | head -n 1)}
    for rt in ${my_route_table[@]}; do
        echo "Delete route: $rt via $IFGW dev $IFNAME"
        ip route del $rt via $IFGW dev $IFNAME
    done
    ip route add default via $IFGW dev $IFNAME
}

# $1 path
save_old_route() {
    ip route list > ${1:-./route-table-$(date +%F-%H%M%S).txt}
}

# setting route needs root permission
check_root() {
    if [ "$UID" != "0" ]; then
        echo "[ERR] You must be super user to run this utility!"
        exit 1
    fi
}

# start
if [ x"$1" = x'set' ]; then
    check_root
    shift
    set_my_route $@
elif [ x"$1" = x'reset' ]; then
    check_root
    shift
    reset_my_route $@
elif [ x"$1" = x'save' ]; then
    shift
    save_old_route $@
else
    cat <<EOF
Set static routes when both Ethernet(eth0) and Wireless(wlan0) are connected.

Usage: $0 [Cmd] [arguments]

Cmds:
    set static-IF [static-GW  [default-IF default-GW]]
        set static routes for static-IF
    reset static-IF [static-GW]
        reset routes, delete added static routes
    save [save-path]
        save ip route list to a file

original example:
 default via 10.xx.yy.1 dev wlan0 proto dhcp src 10.xx.jj.ii metric 600 
 default via 10.mm.nn.1 dev eth0 proto static metric 20100 
 10.mm.nn.0/24 dev eth0 proto kernel scope link src 10.mm.nn.kk metric 100 
 10.xx.yy.0/17 dev wlan0 proto kernel scope link src 10.xx.jj.ii metric 600 

EOF
fi

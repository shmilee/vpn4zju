#!/bin/bash

####################
# Variables
####################
## How many seconds to wait for the ppp to come up each try
TIMEOUT=60
## LAC name in config file
L2TPD_LAC=ZJU
## L2tpServerAddress=('10.5.1.9' '10.5.1.7' '10.5.1.5')
SERVER_ADDR='10.5.1.9'
## static route table
_rt=('10.0.0.0/8'
'58.196.192.0/19'
'58.196.224.0/20'
'210.32.0.0/20'
'210.32.128.0/19'
'210.32.160.0/21'
'210.32.168.0/22'
'210.32.172.0/23'
'210.32.176.0/20'
'222.205.0.0/17')
#_rt+=('210.32.174.0/24') ## zjg maybe

## wait-online by myself, 21s at booting(uptime < 60s)
## default is 'N', network-online.target works better
_WAIT='N' #'Y'

L2TPD_CONTROL_FILE=/var/run/xl2tpd/l2tp-control
L2TPD_CFG_FILE=/etc/xl2tpd/xl2tpd.conf
L2TPD_OPTFILE=/etc/ppp/options.xl2tpd.zju
CHAP_SECRET_FILE=/etc/ppp/chap-secrets

####################
# functions
####################
function usage {
    echo "A utility for ZJU school L2TP VPN."
    echo "Usage: $0 [ACTION]"
    echo
    echo "Actions: "
    echo "      -cfg        Configure."
    echo "      -c          Connect."
    echo "      -d          Disconnect."
    echo "      -h          Show this information."
    echo
}

function check_files {
    if [ ! -e $L2TPD_OPTFILE ]; then
        echo "[ERR] lost $L2TPD_OPTFILE"
        return 1
    fi
    if [ ! -e $L2TPD_CFG_FILE ]; then
        cat > $L2TPD_CFG_FILE <<EOF
[global]							; Global parameters:
port = 1701						 	; * Bind to port 1701
access control = yes				; * Refuse connections without IP match
rand source = dev                   ; * Source for entropy for random
auth file = $CHAP_SECRET_FILE

EOF
    fi
    if [ ! -e $CHAP_SECRET_FILE ]; then
        echo "[ERR] lost $CHAP_SECRET_FILE which is contained in package ppp."
        return 1
    fi
}

function test_connection {
    if [ $_WAIT == Y ]; then
        local i=1
        _uptime=$(cat /proc/uptime | sed 's/\..*$//')
        if [ $_uptime -lt 60 ];then
            while [ $i -le 6 ]; do
                ping -c 1 -q $SERVER_ADDR 2>&1 > /dev/null && return 0
                sleep $i
                let i++
            done
        fi
    else
        ping -c 1 -q $SERVER_ADDR 2>&1 > /dev/null && return 0
    fi
    cat <<EOF
The network connection between your computer and the VPN server was interrupted.
This can be caused by:
  1) VPN server temporarily got down. Change one.
  2) Route table of your computer got corrupted. Restart computer and try again.
  3) You have not logged into campus network. If you are in Students' Dormitory
     of Zijingang Campus, make sure you have passed authentication via 'ShanXun'.
EOF
    return 1
}
function _init {
    _GW=$(ip route get $SERVER_ADDR 2> /dev/null | grep via | awk '{print $3}')
    _IF=$(ip route get $SERVER_ADDR 2> /dev/null | grep via | awk '{print $5}')
    _IFNAME="$(sed -n '/^ifname/ s/ifname //p' $L2TPD_OPTFILE)"
    if [ -z "$_IFNAME" ]; then
        if [ $(expr length $_GW) -ge 6 ]; then
            _IFNAME=ppp0 #YQ
        else
            _IFNAME=ppp1 #ZJG with Shan Xun, ppp0 is used
        fi
    fi
}

function ppp_alive {
    if ip addr show | grep "inet.*$_IFNAME" > /dev/null; then
        return 0  # Yes, connected
    else
        return 1
    fi
}

function setroute {
    _VPN_GW=$(ip addr show dev $_IFNAME | grep "inet.*$_IFNAME" | awk '{print $2}')

    if [ "$1" == up ]; then
        echo "[MSG] Detected gateway: $_GW, PPP device: $_IFNAME"
        echo -n "[MSG] Setting up route table...  "
        for _i in ${_rt[@]}; do
            ip route add $_i via $_GW dev $_IF
        done
        ip route del default
        ip route add default via $_VPN_GW dev $_IFNAME
        echo "Done!"
    elif [ "$1" == down ]; then
        echo -n "[MSG] Reseting default route... "
        for _i in ${_rt[@]}; do
            ip route del $_i
        done
        ip route del default
        ip route add default via $_GW dev $_IF
        echo "Done!"
    else
        echo "[ERR] NEVER HAPPEN!"
    fi
}

function configure {
    echo "[MSG] Configure L2TP VPN for ZJU."
    read -p "Username @[acd] : " username
    read -s -p "Password : " password
    echo
    
    #write_settings
    if grep "^\[lac $L2TPD_LAC\]" $L2TPD_CFG_FILE 2>&1 > /dev/null; then
        sed -i "s|^name.*ZJUVPN ID$|name = $username  ; * ZJUVPN ID|" $L2TPD_CFG_FILE
    else
        cat >> $L2TPD_CFG_FILE <<EOF
[lac $L2TPD_LAC]
lns = $SERVER_ADDR				    ; * Who is our LNS?
redial = yes						; * Redial if disconnected?
redial timeout = 10					; * Wait n seconds between redials
max redials = 5						; * Give up after n consecutive failures
require chap = yes					; * Require CHAP auth. by peer
refuse pap = yes					; * Refuse PAP authentication
require authentication = yes		; * Require peer to authenticate
ppp debug = no						; * Turn on PPP debugging
pppoptfile = $L2TPD_OPTFILE			; * ppp options file for this lac
name = $username					; * ZJUVPN ID

EOF
    fi

    if grep "^$username" $CHAP_SECRET_FILE 2>&1 > /dev/null; then
        sed -i "s|^$username .*$|$username  *  $password  *|" $CHAP_SECRET_FILE
    else
        echo "$username  *  $password  *" >> $CHAP_SECRET_FILE
    fi
    chmod 600 $CHAP_SECRET_FILE

    unset username
    unset password
    echo "[MSG] Configuration saved."
}

function connect {
    echo "c $L2TPD_LAC" > $L2TPD_CONTROL_FILE
    for i in $(seq 0 $TIMEOUT); do
        if ppp_alive; then
            echo " Done!" # Yes, brought up!
            setroute up
            return 0
        fi
        echo -n -e "\\r[MSG] Trying to bring up VPN... $i secs..."
        sleep 1
    done
    echo
    echo "[ERR] Failed to bring up vpn!"
    return 1
}

function disconnect {
    setroute down
    echo -n "[MSG] Disconnecting VPN ... "
    echo "d $L2TPD_LAC" > $L2TPD_CONTROL_FILE
    sleep 1
    echo "Done!"
}

####################
# MAIN
####################
if [ "$UID" != "0" ]; then
    echo "[ERR] You must be super user to run this utility!"
    exit 1
fi
check_files || exit 1
test_connection || exit 1
_init

if [ x"$1" == 'x-cfg' ]; then
    configure
elif [ x"$1" == 'x-c' ]; then
    if ! grep "^\[lac $L2TPD_LAC\]" $L2TPD_CFG_FILE 2>&1 > /dev/null; then
        echo "[MSG] Run ACTION Configure first."
        echo "[MSG] If you run me with systemd, please restart xl2tpd after configuration."
        exit 1
    fi
    if [ ! -e $L2TPD_CONTROL_FILE ]; then
        echo "[ERR] L2tpd daemon not running!"
        exit 1
    fi
    if ppp_alive ; then
        echo "[MSG] VPN already connected."
    else
        connect || exit 1
    fi
elif [ x"$1" == 'x-d' ]; then
    if ! ppp_alive ; then
        echo "[ERR] VPN not connected."
        exit 1
    else
        disconnect
    fi
else
    usage
fi
exit 0

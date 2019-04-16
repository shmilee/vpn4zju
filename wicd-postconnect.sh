#!/bin/bash
# Copyright (C) 2019 shmilee

#Set the parameters passed to this script to meaningful variable names.
connection_type="$1"
essid="$2"
bssid="$3"

#echo ${connection_type} > /tmp/wicd-ZJUWLAN.log
#echo ${essid} >> /tmp/wicd-ZJUWLAN.log
if [[ "${connection_type}" == "wireless" && "${essid}" == 'ZJUWLAN' ]]; then
    zjuwlan login
    #zjuwlan login >> /tmp/wicd-ZJUWLAN.log
fi

#!/bin/bash

VNFM_HOST=$1
VNFM_PORT=$2
VNF_ID=$3
NDN_NAME=$4

VNF_DIR=/doctor/vnf
EGW_DIR=/root/gateway/egw/bin

VAR0="$(ifconfig | grep 10.10.0.)"
IFS=':' read -a myarray0 <<< "$VAR0"
IFS=' ' read -a myarray0 <<< "${myarray0[1]}"
VNF_ADMIN_IP="${myarray0[0]}"

nfd-start &> /var/log/nfd_log
cd /root/mmt/mmt-probe/
./probe -c mmt.conf &
cd /root/mmt/mmt-security/
./mmt_sec_server -a 8080 -f ./output/:5 -s $VNFM_HOST:$VNFM_PORT/doctor/MMTenant/report -b $VNF_ID &

sleep 3
$EGW_DIR/egw -n $NDN_NAME &
sleep 2

python $VNF_DIR/egress_gateway_server.py $VNFM_HOST $VNFM_PORT "$VNF_ADMIN_IP" $HOSTNAME &
tail -f /var/log/dmesg


#!/bin/bash
nfd-start &> /var/log/nfd_log
cd /root/mmt/mmt-probe/
./probe -c mmt.conf &
cd /root/mmt/mmt-security/
./mmt_sec_server -a 8080 -o 10.10.1.107:4999/doctor/api/report -b 123 &
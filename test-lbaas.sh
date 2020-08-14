#!/bin/bash
set -eux

LB_NAME=${LB_NAME:-demo-lb}
LB_FIP=${LB_FIP:-10.60.253.77}
SERVER_NAME=${SERVER_NAME:-demo-lb}
SERVER_FIP=${SERVER_FIP:-10.60.253.41}
SERVER_IMAGE=${SERVER_IMAGE:-CentOS7}
SERVER_FLAVOR=${SERVER_FLAVOR:-general.v1.small}
SERVER_KEYNAME=${SERVER_KEYNAME:-wendy}
SERVER_NET=${SERVER_NET:-p3-internal}
SERVER_SUBNET=${SERVER_SUBNET:-p3-internal}

openstack port show $SERVER_NAME || openstack port create $SERVER_NAME --network $SERVER_NET
ADDRESS=`openstack port show $SERVER_NAME -c fixed_ips -f json | jq -r ".fixed_ips[0].ip_address"`

openstack server show $SERVER_NAME || openstack server create $SERVER_NAME --image $SERVER_IMAGE --key-name $SERVER_KEYNAME --port $SERVER_NAME --flavor $SERVER_FLAVOR --wait
openstack server add floating ip $SERVER_NAME $SERVER_FIP
until curl -m1 $SERVER_FIP; do
    ssh -o StrictHostKeyChecking=no centos@$SERVER_FIP "sudo nohup /usr/libexec/platform-python -m http.server 80" &
    sleep 10
done

openstack loadbalancer show $LB_NAME && openstack loadbalancer delete --cascade $LB_NAME
openstack loadbalancer create --name $LB_NAME --vip-subnet-id $SERVER_SUBNET --wait
openstack loadbalancer listener create --name listener-$LB_NAME --protocol HTTP --protocol-port 80 $LB_NAME --wait
openstack loadbalancer pool create --name pool-$LB_NAME --lb-algorithm ROUND_ROBIN --listener listener-$LB_NAME --protocol HTTP --wait
openstack loadbalancer member create --subnet-id $SERVER_SUBNET --address $ADDRESS --protocol-port 80 pool-$LB_NAME --wait

openstack floating ip set --port `openstack loadbalancer show $LB_NAME -c vip_port_id -f value` $LB_FIP

until curl $LB_FIP; do sleep 10; done

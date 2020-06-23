#!/bin/bash
set -eux

LB_NAME=${LB_NAME:-demo-lb}
LB_FIP=${LB_FIP:-10.60.253.77}
SERVER_FIP=${SERVER_FIP:-10.60.253.41}
SERVER_IMAGE=${SERVER_IMAGE:-CentOS7}
SERVER_FLAVOR=${SERVER_FLAVOR:-general.v1.small}
SERVER_KEYNAME=${SERVER_KEYNAME:-wendy}
SERVER_NET=${SERVER_NET:-p3-internal}
SERVER_SUBNET=${SERVER_SUBNET:-p3-internal}

openstack server show $LB_NAME || {
    openstack server create $LB_NAME --image $SERVER_IMAGE --key-name $SERVER_KEYNAME --network $SERVER_NET --flavor $SERVER_FLAVOR --wait
}
openstack server add floating ip $LB_NAME $SERVER_FIP
ssh -o StrictHostKeyChecking=no centos@$SERVER_FIP sudo yum install -y nginx
ssh -o StrictHostKeyChecking=no centos@$SERVER_FIP sudo systemctl start nginx
ADDRESS=`openstack server show $LB_NAME -c addresses -f value | tr '; ' '\n' | grep $SERVER_NET | cut -f2 -d= | cut -f1 -d,`

openstack loadbalancer show $LB_NAME && openstack loadbalancer delete --cascade $LB_NAME
openstack loadbalancer create --name $LB_NAME --vip-subnet-id $SERVER_SUBNET --wait
openstack loadbalancer listener create --name listener-$LB_NAME --protocol HTTP --protocol-port 80 $LB_NAME --wait
openstack loadbalancer pool create --name pool-$LB_NAME --lb-algorithm ROUND_ROBIN --listener listener-$LB_NAME --protocol HTTP --wait
openstack loadbalancer member create --subnet-id $SERVER_SUBNET --address $ADDRESS --protocol-port 80 pool-$LB_NAME --wait

openstack floating ip set --port `openstack loadbalancer show $LB_NAME -c vip_port_id -f value` $LB_FIP

curl $LB_FIP

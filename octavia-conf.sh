#!/bin/bash
set -eux

OCTAVIA_CONF=${OCTAVIA_CONF:-etc/kayobe/kolla/config/octavia.conf}

until openstack network show lb-mgmt-net; do
    openstack network create lb-mgmt-net --provider-network-type flat --provider-physical-network octavia --project service
done
crudini --set $INIFILE controller_worker amp_boot_network_list `openstack network show lb-mgmt-net -c id -f value`

OCTAVIA_MGMT_SUBNET=${OCTAVIA_MGMT_SUBNET:-172.16.158.0/24}
OCTAVIA_MGMT_SUBNET_START=${OCTAVIA_MGMT_SUBNET_START:-172.16.158.120}
OCTAVIA_MGMT_SUBNET_END=${OCTAVIA_MGMT_SUBNET_END:-172.16.158.220}
until openstack subnet show lb-mgmt-subnet; do
    openstack subnet create --subnet-range $OCTAVIA_MGMT_SUBNET --allocation-pool start=$OCTAVIA_MGMT_SUBNET_START,end=$OCTAVIA_MGMT_SUBNET_END --network lb-mgmt-net lb-mgmt-subnet --project service
done

until openstack security group show lb-mgmt-sec-grp; do
    openstack security group create lb-mgmt-sec-grp --project service
done
openstack security group rule create lb-mgmt-sec-grp --project service --protocol icmp
openstack security group rule create lb-mgmt-sec-grp --project service --protocol tcp --dst-port 22
openstack security group rule create lb-mgmt-sec-grp --project service --protocol tcp --dst-port 9443
crudini --set $INIFILE controller_worker amp_secgroup_list `openstack security group show lb-mgmt-sec-grp -c id -f value`

until openstack flavor show amphora; do
    openstack flavor create --vcpus 1 --ram 1024 --disk 2 "amphora" --private
done
crudini --set $INIFILE controller_worker amp_flavor_id `openstack flavor show amphora -c id -f value`

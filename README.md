# Octavia Scripts

## Generate Production Grade Certificates for Octavia

The following script can be used to generated production grade certificates for Octavia
based on the [upstream docs][1]. Usage:

    export CA_PASS=production-grade-password # required
    export CA_BITS=4096                      # optional (default value)
    export CA_COUNTRY=UK                     # optional (default value)
    export CA_STATE=England                  # optional (default value)
    export CA_LOCATION=Bristol               # optional (default value)
    export CA_PATH=production                # optional (default value)
    ./generate-certs.sh

It is fully compatible with the certificates expected by Train+ releases of
[Kayobe][2] and [Kolla-Ansible][3].

In the case of Kayobe, copy the certs inside `production/etc/octavia/certs/` to
`kayobe-config/etc/kayobe/kolla/config/octavia/`.

## Update `octavia.conf` with network, security group and flavor ID:

    export OCTAVIA_CONF=/path/to/kayobe-config/etc/kayobe/kolla/config/octavia.conf
    export OCTAVIA_MGMT_SUBNET=172.16.158.0/24
    export OCTAVIA_MGMT_SUBNET_START=172.16.158.120
    export OCTAVIA_MGMT_SUBNET_END=172.16.158.220
    ./octavia-conf.sh

## Test Octavia Deployment

To be confident that Octavia is deployed correctly, you can run the following
script (you will need to export some parameters to suit your environment):

    export LB_NAME=demo-lb
    export LB_FIP=10.60.253.77
    export SERVER_FIP=10.60.253.41
    export SERVER_IMAGE=CentOS7
    export SERVER_FLAVOR=general.v1.small
    export SERVER_KEYNAME=wendy
    export SERVER_NET=p3-internal
    export SERVER_SUBNET=p3-internal
    ./test-lbaas.sh

[1]: https://docs.openstack.org/octavia/latest/admin/guides/certificates.html
[2]: https://docs.openstack.org/kayobe/latest/configuration/kolla-ansible.html
[3]: https://docs.openstack.org/kolla-ansible/latest/

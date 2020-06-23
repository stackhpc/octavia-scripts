# Generate Production Grade Certificates for Octavia

This repo can be used to generated production grade certificates for Octavia
based on the [upstream docs][1].

Usage:

    export CA_PASS=production-grade-password # required
    export CA_BITS=4096                      # optional (default value)
    export CA_COUNTRY=UK                     # optional (default value)
    export CA_STATE=England                  # optional (default value)
    export CA_LOCATION=Bristol               # optional (default value)
    export CA_PATH=production                # optional (default value)
    ./octavia-certs.sh

It is fully compatible with the certificates expected by Train+ releases of
[Kayobe][2] and [Kolla-Ansible][3].

In the case of Kayobe, copy the certs inside `production/etc/octavia/certs/` to
`kayobe-config/etc/kayobe/kolla/config/octavia/`.

[1]: https://docs.openstack.org/octavia/latest/admin/guides/certificates.html
[2]: https://docs.openstack.org/kayobe/latest/configuration/kolla-ansible.html
[3]: https://docs.openstack.org/kolla-ansible/latest/

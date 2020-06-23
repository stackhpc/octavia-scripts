#!/bin/bash
set -eux

CA_BITS=${CA_BITS:-4096}
CA_COUNTRY=${CA_COUNTRY:-UK}
CA_STATE=${CA_STATE:-England}
CA_LOCATION=${CA_LOCATION:-Bristol}
CA_PATH=${CA_PATH:-production}

mkdir $CA_PATH
chmod 700 $CA_PATH
cd $CA_PATH

mkdir server_ca
mkdir client_ca

###### Server Root CA
cd server_ca
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

# Create the server CA private key
# Note: This uses short key lengths to save entropy in the test gates.
#       This is not recommended for deployment use!
openssl genrsa -aes128 -out private/ca.key.pem -passout pass:$CA_PASS $CA_BITS
chmod 400 private/ca.key.pem

# Create the server CA root certificate
openssl req -config ../../openssl.cnf -key private/ca.key.pem -new -x509 -sha256 -extensions v3_ca -days 7300 -out certs/ca.cert.pem -subj "/C=$CA_COUNTRY/ST=$CA_STATE/L=$CA_LOCATION/O=OpenStack/OU=Octavia/CN=ServerRootCA" -passin pass:$CA_PASS

###### Client Root CA
cd ../client_ca
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

# Create the client CA private key
# Note: This uses short key lengths to save entropy in the test gates.
#       This is not recommended for deployment use!
openssl genrsa -aes128 -out private/ca.key.pem -passout pass:$CA_PASS $CA_BITS
chmod 400 private/ca.key.pem

# Create the client CA root certificate
openssl req -config ../../openssl.cnf -key private/ca.key.pem -new -x509 -sha256 -extensions v3_ca -days 7300 -out certs/ca.cert.pem -subj "/C=$CA_COUNTRY/ST=$CA_STATE/L=$CA_LOCATION/O=OpenStack/OU=Octavia/CN=ClientRootCA" -passin pass:$CA_PASS

###### Create the controller client key and certificate
openssl genrsa -aes128 -out private/client.key.pem -passout pass:$CA_PASS $CA_BITS

# Create the controller client certificate signing request
openssl req -config ../../openssl.cnf -key private/client.key.pem -new -sha256 -out csr/client.csr.pem -subj "/C=$CA_COUNTRY/ST=$CA_STATE/L=$CA_LOCATION/O=OpenStack/OU=Octavia/CN=OctaviaController" -passin pass:$CA_PASS

# Create the controller client certificate
openssl ca -config ../../openssl.cnf -extensions usr_cert -days 7300 -notext -md sha256 -in csr/client.csr.pem -out certs/client.cert.pem -passin pass:$CA_PASS -batch

# Build the cancatenated client cert and key
openssl rsa -in private/client.key.pem -out private/client.cert-and-key.pem -passin pass:$CA_PASS

cat certs/client.cert.pem >> private/client.cert-and-key.pem

# We are done with the client CA
cd ..

###### Stash the octavia default cert files
mkdir -p etc/octavia/certs
chmod 700 etc/octavia/certs
cp server_ca/private/ca.key.pem etc/octavia/certs/server_ca.key.pem
chmod 700 etc/octavia/certs/server_ca.key.pem
cp server_ca/certs/ca.cert.pem etc/octavia/certs/server_ca.cert.pem
cp client_ca/certs/ca.cert.pem etc/octavia/certs/client_ca.cert.pem
cp client_ca/private/client.cert-and-key.pem etc/octavia/certs/client.cert-and-key.pem
chmod 700 etc/octavia/certs/client.cert-and-key.pem

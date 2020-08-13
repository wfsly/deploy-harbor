work_dir=$(pwd)

work_dir=${1:-$work_dir}
cert_dir=$work_dir/config/cert

echo $cert_dir

default_domain="116.196.117.242"
domain=${2:-$default_domain}

# 生成nginx https证书
openssl genrsa -out $cert_dir/ca.key 4096

openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=$domain" \
 -key $cert_dir/ca.key \
 -out $cert_dir/ca.crt

openssl genrsa -out $cert_dir/$domain.key 4096
cp $cert_dir/$domain.key $cert_dir/server.key

openssl req -sha512 -new \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=$domain" \
    -key $cert_dir/$domain.key \
    -out $cert_dir/$domain.csr

cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = IP:$domain
EOF

openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA $cert_dir/ca.crt -CAkey $cert_dir/ca.key -CAcreateserial \
    -in $cert_dir/$domain.csr \
    -out $cert_dir/$domain.crt
cp $cert_dir/$domain.crt $cert_dir/server.crt

# 生成core和registry token验证证书
openssl genrsa -out $cert_dir/private_key.pem 4096
openssl req -new -x509 \
	-subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=$domain" \
	-key $cert_dir/private_key.pem -out $cert_dir/root.crt -days 3650

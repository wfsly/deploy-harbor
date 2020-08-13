# harbor/
#  config
work_dir="/root/harbor"

mkdir -p /data/database
chown -R 999:999 /data/database
mkdir -p /data/registry
chown -R 10000:10000 /data/registry
mkdir -p /data/redis
chown -R 999:999 /data/redis
mkdir -p /data/chart_storage
chown -R 10000:10000 /data/chart_storage


# create network
docker network create -d bridge harbor
docker network create -d bridge chartmuseum

# run postgresql
docker run --name postgresql -d --network harbor \
-v /data/database/:/var/lib/postgresql/data:z \
goharbor/harbor-db:v1.10.4

# run redis
docker run --name redis -d --network harbor \
-v /data/redis/:/var/lib/redis \
goharbor/redis-photon:v1.10.4

# run core
docker run -d --network harbor --name core   -p 8080:8080 \
--env-file $work_dir/config/core/env \
-v $work_dir/config/core/app.conf:/etc/core/app.conf \
-v $work_dir/config/core/secretKey:/etc/core/key \
-v $work_dir/config/cert/private_key.pem:/etc/core/private_key.pem \
goharbor/harbor-core:v1.10.4

# run registry
docker run --network harbor  -d --name registry -p 5000:5000 \
-v /data/registry/:/storage:z \
-v $work_dir/config/registry/config.yml:/etc/registry/config.yml \
-v $work_dir/config/cert/root.crt:/etc/registry/root.crt \
goharbor/registry-photon:v1.10.4

# run portal
docker run -d --network harbor  --name portal \
-v $work_dir/config/portal/nginx.conf:/etc/nginx/nginx.conf \
goharbor/harbor-portal:v1.10.4

# run nginx
docker run -d --network harbor  --name nginx -p 80:8080 -p 443:8443 \
-v $work_dir/config/nginx/nginx.conf:/etc/nginx/nginx.conf \
-v $work_dir/config/cert/server.key:/etc/cert/server.key \
-v $work_dir/config/cert/server.crt:/etc/cert/server.crt \
goharbor/nginx-photon:v1.10.4

# run chartmuseum
docker run -d --network chartmuseum  --name chartmuseum  \
--env-file $work_dir/config/chartmuseum/env \
-v /data/chart_storage:/chart_storage:z \
-v $work_dir/config/chartmuseum:/etc/chartserver:z \
goharbor/chartmuseum-photon:v1.10.4

docker network connect chartmuseum core
docker network connect chartmuseum redis

work_dir="/root/harbor"
work_dir=${1:-$work_dir}

domain="127.0.0.1"
domain=${2:-$domain}

# 替换registry/config.yml realm
sed "s|realm: .*|realm: https://$domain/service/token|g" -i $work_dir/config/registry/config.yml

# 替换core/env EXT_ENDPOINT
sed "s|EXT_ENDPOINT=.*|EXT_ENDPOINT=https://$domain|g" -i $work_dir/config/core/env

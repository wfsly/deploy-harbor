yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engin

yum install -y yum-utils


yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

yum install -y docker-ce docker-ce-cli containerd.io

# 或使用rpm包本地安装
# work_dir="/root/harbor/"
# yum localinstall -y rpm/*.rpm


systemctl enable docker
systemctl start docke

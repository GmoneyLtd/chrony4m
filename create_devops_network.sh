#!/bin/bash

export SUBNET_PREFIX=172.18.16
export NETWORK_NAME=ecs4play

# 检查网络是否存在
if docker network inspect $NETWORK_NAME > /dev/null 2>&1; then
    echo "Network '$NETWORK_NAME' already exists. Attempting to remove it..."
    # 删除现有网络
    docker network rm $NETWORK_NAME
    if [ $? -ne 0 ]; then
        echo "Failed to remove existing network '$NETWORK_NAME'."
        exit 1
    fi
fi

# 创建网络
docker network create \
  --driver bridge \
  --subnet=${SUBNET_PREFIX}.0/24 \
  --ip-range=${SUBNET_PREFIX}.0/25 \
  --gateway=${SUBNET_PREFIX}.1 \
  --ipv6 \
  --subnet fd00:0:0:0600::/56 \
  --gateway fd00:0:0:0600::1 \
  --label com.play.description="hello world" \
  --opt com.docker.network.bridge.name=$NETWORK_NAME \
  --opt com.docker.network.bridge.enable_ip_masquerade=true \
  --opt com.docker.network.bridge.enable_icc=true \
  $NETWORK_NAME

# 检查命令的退出状态
if [ $? -eq 0 ]; then
    echo "Network '$NETWORK_NAME' created successfully."
else
    echo "Failed to create network '$NETWORK_NAME'."
    exit 1
fi

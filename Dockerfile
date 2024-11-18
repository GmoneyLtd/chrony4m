# 使用最新版本的 Alpine 作为基础镜像
FROM alpine:latest

# 构建参数
ARG BUILD_DATE

# 关于这个容器的一些信息
LABEL build_info="chrony4m build-date:- ${BUILD_DATE}"
LABEL maintainer="apuer <apuer911@gmail.com>"

# 更新软件包列表，安装 chrony 和 libfaketime
RUN echo apk update && \
    apk add --no-cache chrony tzdata libfaketime && \
    rm -rf /var/cache/apk/*

# 设置环境变量以使用 libfaketime
ENV LD_PRELOAD="/usr/lib/faketime/libfaketime.so.1"
ENV FAKETIME="@2024-11-01 00:00:00"

# 复制启动脚本到容器中
COPY assets/startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

# NTP 端口
EXPOSE 123/udp

# 设置健康检查
HEALTHCHECK CMD chronyc -n tracking || exit 1

# start chronyd in the foreground
ENTRYPOINT [ "/bin/sh", "/opt/startup.sh" ]

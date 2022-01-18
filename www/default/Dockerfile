FROM golang:alpine AS builder

# 为我们的镜像设置必要的环境变量

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    GOPROXY=https://goproxy.cn

# 移动到工作目录：/build
WORKDIR /build
#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk update && apk add tzdata
# 复制项目中的 go.mod 和 go.sum文件并下载依赖信息
COPY go.mod .
COPY go.sum .
#RUN go mod download
RUN go mod tidy
# 将代码复制到容器中
COPY . .
RUN pwd && ls
# 将我们的代码编译成二进制可执行文件 app
RUN  go build -ldflags="-w -s" -a -installsuffix cgo -o goapp .

###################
# 接下来创建一个小镜像 alpine 或者 scratch
###################
FROM alpine

#WORKDIR /www
# 从builder镜像中把/dist/app 拷贝到当前目录
COPY --from=builder /build/goapp .
# 设置Go程序权限
RUN chmod +x /www/goapp

COPY --from=builder /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

EXPOSE 9090
# 启动容器需要运行的命令
#CMD ["/goapp","-c", "/config/settings.yml"]
CMD ["goapp"]
#ENTRYPOINT ["/goapp", "conf/config.ini"]
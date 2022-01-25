FROM golang:alpine AS builder

# 为我们的镜像设置必要的环境变量

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    GOPROXY=https://goproxy.cn
#https://goproxy.cn https://goproxy.io
# 移动到工作目录：/build
WORKDIR /build
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk update && apk add tzdata upx
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
#使用upx压缩文件
RUN upx goapp
# 移动到用于存放生成的二进制文件的 /dist 目录
WORKDIR /dist

# 将二进制文件从 /build 目录复制到这里
RUN cp /build/goapp .

# 声明服务端口
EXPOSE 9090

# 启动容器时运行的命令、不编译二进制文件可使用go环境运行 CMD ["go", "run", "/dist/main.go"]
CMD ["/dist/goapp"]

###################
# 接下来创建一个小镜像 alpine 或者 scratch
###################
#FROM alpine

#WORKDIR /www
# 从builder镜像中把/dist/app 拷贝到当前目录
#COPY --from=builder /build/goapp .
# 设置Go程序权限
#RUN chmod +x ./goapp

#COPY --from=builder /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#EXPOSE 9090
# 启动容器需要运行的命令
#CMD ["/goapp","-c", "/config/settings.yml"]
#CMD ["goapp"]
#ENTRYPOINT ["/goapp", "conf/config.ini"]
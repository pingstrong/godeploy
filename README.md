goDeploy（Docker + Nginx + MySQL8/5 + Mariadb + Golang + Redis + Mongodb + ElasticSearch + Jenkins + Gitlab + Postgrepsql + RabbitMQ）是一款全功能的PHP单点环境部署服务。

-----------------------------------
使用前请联系作者：pingstrong@163.com
微信V：pingstrong
-----------------------------------

项目特点：

. 支持绑定**任意多个域名**
. 支持**HTTPS和HTTP/2**
. **PHP源代码、MySQL数据、配置文件、日志文件**都可在Host中直接修改查看
. 可一键选配常用服务：
    - 多go版本：17,18
    - Web服务：Nginx、Openresty
    - 数据库：MySQL5、MySQL8、Redis、memcached、MongoDB、ElasticSearch
    - 消息队列：RabbitMQ
    - 辅助工具：Kibana、Logstash、phpMyAdmin、phpRedisAdmin、AdminMongo
10. 实际项目中应用，确保`100%`可用
11. 所有镜像源于[Docker官方仓库](https://hub.docker.com)，安全可靠
11. 一次配置，**Windows、Linux、MacOs**皆可用

# 目录
- [1.目录结构](#1目录结构)
- [2.快速使用](#2快速使用)
- [4.管理命令](#4管理命令)
    - [4.1 服务器启动和构建命令](#41-服务器启动和构建命令)
    - [4.2 添加快捷命令](#42-添加快捷命令)
- [5.使用Log](#5使用log)
    - [5.1 Nginx日志](#51-nginx日志)
    - [5.2 PHP-FPM日志](#52-php-fpm日志)
    - [5.3 MySQL日志](#53-mysql日志)
- [6.数据库管理](#6数据库管理)
    - [6.1 phpMyAdmin](#61-phpmyadmin)
    - [6.2 phpRedisAdmin](#62-phpredisadmin)
- [7.在正式环境中安全使用](#7在正式环境中安全使用)
- [8.常见问题](#8常见问题)
    - [8.1 如何在PHP代码中使用curl？](#81-如何在php代码中使用curl)
    - [8.2 Docker使用cron定时任务](#82-Docker使用cron定时任务)
    - [8.3 Docker容器时间](#83-Docker容器时间)
    - [8.4 如何连接MySQL和Redis服务器](#84-如何连接MySQL和Redis服务器)


## 1.目录结构

```
/
├── data                        数据库数据目录
│   ├── esdata                  ElasticSearch 数据目录
│   ├── mongo                   MongoDB 数据目录
│   ├── mysql                   MySQL8 数据目录
│   └── Mariadb                 Mariadb 数据目录
├── services                    服务构建文件和配置文件目录
│   ├── elasticsearch           ElasticSearch 配置文件目录
│   ├── mysql                   MySQL8 配置文件目录
│   ├── mysql5                  MySQL5 配置文件目录
│   ├── nginx                   Nginx 配置文件目录
│   ├── go                      go配置目录
│   └── redis                   Redis 配置目录
├── logs                        日志目录
├── docker-compose.sample.yml   Docker 服务配置示例文件
├── env.smaple                  环境配置示例文件
└── www                         代码目录
```

## 2.快速使用
1. 本地安装
    - `git`
    - `Docker`(系统需为Linux，Windows 10 Build 15063+，或MacOS 10.12+，且必须要`64`位）
    - `docker-compose 1.7.0+`
2. `clone`项目：
    ```
    $ git clone https://github.com/X.git
    ```
3. 如果不是`root`用户，还需将当前用户加入`docker`用户组：
    ```
    $ sudo gpasswd -a ${USER} docker
    ```
4. 拷贝并命名配置文件（Windows系统请用`copy`命令），启动：
    ```
    $ cd dnmp                                           # 进入项目目录
    $ cp env.sample .env                                # 复制环境变量文件
    $ cp docker-compose.sample.yml docker-compose.yml   # 复制 docker-compose 配置文件。默认启动3个服务：
                                                        # Nginx、PHP7和MySQL8。要开启更多其他服务，如Redis、
                                                        # PHP5.6、PHP5.4、MongoDB，ElasticSearch等，请删
                                                        # 除服务块前的注释
    $ docker-compose up                                 # 启动
    ```
5. 在浏览器中访问：`http://localhost`或`https://localhost`(自签名HTTPS演示)就能看到效果，PHP代码在文件`./www/localhost/index.php`。
   
**方法二：容器内使用composer命令**

还有另外一种方式，就是进入容器，再执行`composer`命令，以PHP7容器为例：
```bash
docker exec -it php /bin/sh
cd /www/localhost
composer update
```

## 4.管理命令
### 4.1 服务器启动和构建命令
如需管理服务，请在命令后面加上服务器名称，例如：
```bash
$ docker-compose up                         # 创建并且启动所有容器
$ docker-compose up -d                      # 创建并且后台运行方式启动所有容器
$ docker-compose up nginx php mysql         # 创建并且启动nginx、php、mysql的多个容器


$ docker-compose start php                  # 启动服务
$ docker-compose stop php                   # 停止服务
$ docker-compose restart php                # 重启服务
$ docker-compose build php                  # 构建或者重新构建服务

$ docker-compose rm php                     # 删除并且停止php容器
$ docker-compose down                       # 停止并删除容器，网络，图像和挂载卷
```

### 4.2 添加快捷命令
在开发的时候，我们可能经常使用`docker exec -it`进入到容器中，把常用的做成命令别名是个省事的方法。

首先，在主机中查看可用的容器：
```bash
$ docker ps           # 查看所有运行中的容器
$ docker ps -a        # 所有容器
```
输出的`NAMES`那一列就是容器的名称，如果使用默认配置，那么名称就是`nginx`、`php`、`php56`、`mysql`等。

然后，打开`~/.bashrc`或者`~/.zshrc`文件，加上：
```bash
alias dnginx='docker exec -it nginx /bin/sh'
alias dphp='docker exec -it php /bin/sh'
alias dphp56='docker exec -it php56 /bin/sh'
alias dphp54='docker exec -it php54 /bin/sh'
alias dmysql='docker exec -it mysql /bin/bash'
alias dredis='docker exec -it redis /bin/sh'
```
下次进入容器就非常快捷了，如进入php容器：
```bash
$ dphp
```

### 4.3 查看docker网络
```sh
ifconfig docker0
```
用于填写`extra_hosts`容器访问宿主机的`hosts`地址

## 5.使用Log

Log文件生成的位置依赖于conf下各log配置的值。

### 5.1 Nginx日志
Nginx日志是我们用得最多的日志，所以我们单独放在根目录`log`下。

`log`会目录映射Nginx容器的`/var/log/nginx`目录，所以在Nginx配置文件中，需要输出log的位置，我们需要配置到`/var/log/nginx`目录，如：
```
error_log  /var/log/nginx/nginx.localhost.error.log  warn;
```


### 5.2 PHP-FPM日志
大部分情况下，PHP-FPM的日志都会输出到Nginx的日志中，所以不需要额外配置。

另外，建议直接在PHP中打开错误日志：
```php
error_reporting(E_ALL);
ini_set('error_reporting', 'on');
ini_set('display_errors', 'on');
```

如果确实需要，可按一下步骤开启（在容器中）。

1. 进入容器，创建日志文件并修改权限：
    ```bash
    $ docker exec -it php /bin/sh
    $ mkdir /var/log/php
    $ cd /var/log/php
    $ touch php-fpm.error.log
    $ chmod a+w php-fpm.error.log
    ```
2. 主机上打开并修改PHP-FPM的配置文件`conf/php-fpm.conf`，找到如下一行，删除注释，并改值为：
    ```
    php_admin_value[error_log] = /var/log/php/php-fpm.error.log
    ```
3. 重启PHP-FPM容器。

### 5.3 MySQL日志
因为MySQL容器中的MySQL使用的是`mysql`用户启动，它无法自行在`/var/log`下的增加日志文件。所以，我们把MySQL的日志放在与data一样的目录，即项目的`mysql`目录下，对应容器中的`/var/lib/mysql/`目录。
```bash
slow-query-log-file     = /var/lib/mysql/mysql.slow.log
log-error               = /var/lib/mysql/mysql.error.log
```
以上是mysql.conf中的日志文件的配置。



## 6.数据库管理
本项目默认在`docker-compose.yml`中开启了用于MySQL在线管理的*phpMyAdmin*，以及用于redis在线管理的*phpRedisAdmin*，可以根据需要修改或删除。

### 6.1 phpMyAdmin
phpMyAdmin容器映射到主机的端口地址是：`8080`，所以主机上访问phpMyAdmin的地址是：
```
http://localhost:8080
```

MySQL连接信息：
- host：(本项目的MySQL容器网络)
- port：`3306`
- username：（手动在phpmyadmin界面输入）
- password：（手动在phpmyadmin界面输入）

### 6.2 phpRedisAdmin
phpRedisAdmin容器映射到主机的端口地址是：`8081`，所以主机上访问phpMyAdmin的地址是：
```
http://localhost:8081
```

Redis连接信息如下：
- host: (本项目的Redis容器网络)
- port: `6379`


### 7.在正式环境中安全使用
要在正式环境中使用，请：
1. 在php.ini中关闭XDebug调试
2. 增强MySQL数据库访问的安全策略
3. 增强redis访问的安全策略
4. php启用opcache

### php定时器

* * * * * docker exec php72_crontab  sh -c "cd /path-to-your-project && sudo -u www-data php artisan schedule:run  >> ./schedule_run.log  2>&1"

#随时提取docker的容器ID或者名称
* * * * * docker exec `docker ps -a | grep 'php72_crontab' |awk '{print $1}'` /var/www/data_rsync >> /var/log/rsync.log 2>&1


### 负载均衡、高并发

1、采用docker-compose scale server=num 扩展服务容器数量

    docker-compose up --scale php72=10 -d
2、内置swarm集群管理

3、第三方集群容器编排工具kubernetes

### dockerfile 的问题 FROM alpine:3.8 temporary error (try again later)

    sudo systemctl daemon-reload
    sudo systemctl restart docker
### 安装composer后报错proc_open(): fork failed - Cannot allocate memory

	容器在命令行环境依次运行以下三条命令
	dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
	mkswap /var/swap.1
	swapon /var/swap.1
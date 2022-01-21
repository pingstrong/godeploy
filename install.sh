#!/bin/bash
# Author：  spring <pingstrong@163.com>
# Notes: Support Centos7^ || Fedora OS install docker shell.

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
clear
printf "
#######################################################################
       SingleDockerDeploy Installer for CentOS/Ubuntu/Debian/RedHat/Fedora
       For more information please contact Wechat:pingstrong     #
#######################################################################
"
#country：1 china，2 foreign
CountryId=1 
RegistryMirrors="https://mbv59fdk.mirror.aliyuncs.com"
#   ------ check user //start ------
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script！"; exit 1; }
#   ------ check user //end ------

cat <<EOF
*******************************
The following is optional
*******************************
    1) China(default)
    2) Foreign
*******************************
EOF
read -p "Please select country?" AreaID
if [ ! -n "$AreaID" ] ;then
  echo "you have not select country, default set is china! \n"
elif [ $AreaID == 1 ]; then
  echo "you have select china area . \n" 
else
  echo "you have select foreign area . \n"
  CountryId=2
  RegistryMirrors="https://docker.com"
fi

#   ------ functions //start -------
Set_Timezone()
{
    Echo_Blue "Setting timezone..."
    rm -rf /etc/localtime
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

Disable_Selinux()
{
    if [ -s /etc/selinux/config ]; then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    fi
}

Make_Install()
{
    make -j `grep 'processor' /proc/cpuinfo | wc -l`
    if [ $? -ne 0 ]; then
        make
    fi
    make install
}

Download_Files()
{
    local URL=$1
    local FileName=$2
    if [ -s "${FileName}" ]; then
        echo "${FileName} [found]"
    else
        echo "Notice: ${FileName} not found!!!download now..."
        wget -c --progress=bar:force --prefer-family=IPv4 --no-check-certificate ${URL}
    fi
}

function CheckOS() 
{
	if [[ -e /etc/debian_version ]]; then
		OS="debian"
		source /etc/os-release

		if [[ $ID == "debian" || $ID == "raspbian" ]]; then
			if [[ $VERSION_ID -lt 9 ]]; then
				echo "⚠️ Your version of Debian is not supported."
				echo ""
				echo "However, if you're using Debian >= 9 or unstable/testing then you can continue, at your own risk."
				echo ""
				until [[ $CONTINUE =~ (y|n) ]]; do
					read -rp "Continue? [y/n]: " -e CONTINUE
				done
				if [[ $CONTINUE == "n" ]]; then
					exit 1
				fi
			fi
		elif [[ $ID == "ubuntu" ]]; then
			OS="ubuntu"
			MAJOR_UBUNTU_VERSION=$(echo "$VERSION_ID" | cut -d '.' -f1)
			if [[ $MAJOR_UBUNTU_VERSION -lt 16 ]]; then
				echo "⚠️ Your version of Ubuntu is not supported."
				echo ""
				echo "However, if you're using Ubuntu >= 16.04 or beta, then you can continue, at your own risk."
				echo ""
				until [[ $CONTINUE =~ (y|n) ]]; do
					read -rp "Continue? [y/n]: " -e CONTINUE
				done
				if [[ $CONTINUE == "n" ]]; then
					exit 1
				fi
			fi
		fi
	elif [[ -e /etc/system-release ]]; then
		source /etc/os-release
		if [[ $ID == "fedora" ]]; then
			OS="fedora"
		fi
		if [[ $ID == "centos" ]]; then
			OS="centos"
			if [[ ! $VERSION_ID =~ (7|8) ]]; then
				echo "⚠️ Your version of CentOS is not supported."
				echo ""
				echo "The script only support CentOS 7 and CentOS 8."
				echo ""
				exit 1
			fi
		fi
		if [[ $ID == "amzn" ]]; then
			OS="amzn"
			if [[ $VERSION_ID != "2" ]]; then
				echo "⚠️ Your version of Amazon Linux is not supported."
				echo ""
				echo "The script only support Amazon Linux 2."
				echo ""
				exit 1
			fi
		fi
	elif [[ -e /etc/arch-release ]]; then
		OS=arch
	else
		echo "Looks like you aren't running this installer on a Debian, Ubuntu, Fedora, CentOS, Amazon Linux 2 or Arch Linux system"
		exit 1
	fi
}

Install_Depen_Packages()
{
    if [[ $OS =~ (debian|ubuntu) ]]; then
	 	sudo apt update -y
        #for packages in  net-tools.x86_64 git vim httpd-tools curl-devel openssl openssl-devel net-tools;
        #do apt -y install $packages; done
	elif [[ $OS =~ (centos|amzn) ]]; then
		#yum install -y unbound
		sudo yum install -y epel-release
        sudo yum -y update
        echo "[+] Yum installing dependent packages..."
        for packages in  net-tools.x86_64 git vim httpd-tools iftop lsof screen make wget make cmake gcc gcc-c++ gcc-g77  file  autoconf  wget crontabs  unzip tar curl curl-devel openssl openssl-devel net-tools;
        do yum -y install $packages; done

	elif [[ $OS == "fedora" ]]; then
		dnf install -y git


	elif [[ $OS == "arch" ]]; then
		pacman -Syu --noconfirm unbound

	fi
}

OptimizeSys()
{
    # /etc/security/limits.conf
    [ -e /etc/security/limits.d/*nproc.conf ] && rename nproc.conf nproc.conf_bk /etc/security/limits.d/*nproc.conf
    sed -i '/^# End of file/,$d' /etc/security/limits.conf
cat >> /etc/security/limits.conf <<EOF
# End of file
* soft nproc 1000000
* hard nproc 1000000
* soft nofile 1000000
* hard nofile 1000000
EOF

    ulimit -SHn 1024000
    if [[ $OS =~ (centos|amzn) ]]; then
        echo "ulimit -SHn 1024000" >> /etc/rc.d/rc.local
        source /etc/rc.d/rc.local
    fi

cat > /etc/sysctl.conf<<EOF

#修改消息队列长度
kernel.msgmnb = 65536
kernel.msgmax = 65536

net.ipv4.tcp_syncookies = 0
net.ipv4.ip_forward = 1
net.core.netdev_max_backlog = 32768
net.core.somaxconn = 32768
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.icmp_echo_ignore_all = 1

EOF

    sudo sysctl -p
}


RemoveDocker()
{
    if [[ $OS =~ (debian|ubuntu) ]]; then
	 	sudo apt-get remove docker docker-engine docker.io containerd runc

	elif [[ $OS =~ (centos|amzn) ]]; then
		# 
        sudo yum remove docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-engine

	elif [[ $OS == "fedora" ]]; then
		echo "$OS is not supoort remove docker"
        exit 1

	elif [[ $OS == "arch" ]]; then
		echo "$OS is not supoort remove docker"
        exit 1

	fi
}

InstallDocker()
{
    if [[ $OS =~ (debian|ubuntu) ]]; then
	 	sudo apt-get install \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo apt-key fingerprint 0EBFCD88
        sudo add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) \
            stable"
        sudo apt-get update
        sudo apt-get install docker-ce docker-ce-cli containerd.io -y
        sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
	elif [[ $OS =~ (centos|amzn) ]]; then
		#
        #if [[ $CountryId == 1 ]]; then
            # step 1: 安装必要的一些系统工具
            sudo yum install -y yum-utils device-mapper-persistent-data lvm2
            # Step 2: 添加软件源信息
            sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
            # Step 3: 更新并安装Docker-CE 官方软件源默认启用了最新的软件
            #sudo yum makecache fast 
            #sudo yum localinstall -y ./package/centos/containerd.io-1.2.13-3.2.fc30.x86_64
            sudo yum -y install docker-ce docker-ce-cli containerd.io
            curl -L https://get.daocloud.io/docker/compose/releases/download/1.26.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
            #sudo curl -L "https://gitee.com/thinkpanax/dockerCompose/repository/archive/v1.25?format=tar.gz" -o ./v1.25.tar.gz
            #sudo tar -zxvf ./v1.25.tar.gz && cp ./dockerCompose/docker-compose /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && rm -rf dockerCompose
        #else
        #    sudo yum install -y yum-utils \
        #        device-mapper-persistent-data \
        #        lvm2
        #    sudo yum-config-manager \
        #        --add-repo \
        #        https://download.docker.com/linux/centos/docker-ce.repo
            #sudo yum install -y https://download.docker.com/linux/fedora/30/x86_64/stable/Packages/containerd.io-1.2.13-3.2.fc30.x86_64.rpm
         #   sudo yum -y install docker-ce docker-ce-cli containerd.io
         #   sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        #    sudo chmod +x /usr/local/bin/docker-compose
        #fi
         
	elif [[ $OS == "fedora" ]]; then
		echo "$OS is not supoort install docker"
        exit 1

	elif [[ $OS == "arch" ]]; then
		echo "$OS is not supoort install docker"
        exit 1

	fi

    # 开启Docker服务
	sudo systemctl start docker
	sudo systemctl daemon-reload
	sudo systemctl enable docker
    
}

SetDockerMirror()
{
    cat >> /etc/docker/daemon.json <<EOF
{
"registry-mirrors": ["$RegistryMirrors"]
}
EOF
    if [[ $OS =~ (debian|ubuntu) ]]; then
	 	sudo systemctl daemon-reload
        sudo systemctl restart docker
        sudo systemctl enable docker

	elif [[ $OS =~ (centos|amzn) ]]; then
		#
        sudo systemctl daemon-reload
        sudo systemctl restart docker
        sudo systemctl enable docker
	elif [[ $OS == "fedora" ]]; then
		echo "$OS is not supoort  setmirror"
        exit 1

	elif [[ $OS == "arch" ]]; then
		echo "$OS is not supoort  setmirror"
        exit 1

	fi
    
}

FirewallSetting()
{
    echo "Firewall setting ...... "
}

DeployContainer()
{
    sudo cp env.sample .env
    sudo cp docker-compose.sample.yml docker-compose.yml
    docker-compose up -d
}

ChmodDirPermission()
{
    chmod 777 ./data/esdata -R
}
#   ------ functions //end ------

#check os
CheckOS
#   ------ install tools //start ------
Install_Depen_Packages
#   ------ install tools //end ------

#   ------ os optimize system //start ------
Disable_Selinux
OptimizeSys

#   ------ os optimize system //end ------

#   ------  install docker //start ------
RemoveDocker
InstallDocker
SetDockerMirror
# firewall setting,include protocol/port
#firewall-cmd --permanent --add-masquerade
FirewallSetting
#   ------  install docker //end ------

#   ---- deploy service and code //start ------
#Download_Files ${Download_Mirror}/lib/tcmalloc/${TCMalloc_Ver}.tar.gz ${TCMalloc_Ver}.tar.gz
DeployContainer
ChmodDirPermission
#   ------ deploy service and code //end ------
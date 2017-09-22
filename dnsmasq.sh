#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
Green_font="\033[32m" && Red_font="\033[31m" && Font_suffix="\033[0m"
Info="${Green_font}[Info]${Font_suffix}"
Error="${Red_font}[Error]${Font_suffix}"
echo -e "${Green_font}
#======================================
# Project: dnsmasq
# Version: 1.0
# Author: nanqinlang
# Blog:   https://www.nanqinlang.com
# Github: https://github.com/nanqinlang
#======================================${Font_suffix}"

#check system
check_system(){
	cat /etc/issue | grep -q -E -i "debian" && release="debian" 
	cat /etc/issue | grep -q -E -i "ubuntu" && release="ubuntu"
	if [[ "${release}" = "debian" || "${release}" != "ubuntu" ]]; then 
	echo -e "${Info} system is ${release}"
	else echo -e "${Error} not support!" && exit 1
	fi
}

#check root
check_root(){
	if [[ "`id -u`" = "0" ]]; then
	echo -e "${Info} user is root"
	else echo -e "${Error} must be root user" && exit 1
	fi
}

#determine workplace directory
directory(){
	[[ ! -d /home/dnsmasq-installation ]] && mkdir -p /home/dnsmasq-installation
	cd /home/dnsmasq-installation
}

gcc(){
	sys_ver=`grep -oE  "[0-9.]+" /etc/issue`

	if [[ "${sys_ver}" = "7" ]]; then
		mv /etc/apt/sources.list /etc/sources.list
		wget -P /home/tcp_nanqinlang https://raw.githubusercontent.com/SuzukazeAoran/sources.list/master/us.sources.list && mv /home/tcp_nanqinlang/us.sources.list /etc/apt/sources.list
		apt-get update && apt-get install build-essential -y && apt-get update
		rm /etc/apt/sources.list && mv /etc/sources.list /etc/apt/sources.list
		apt-get update
	else
		apt-get update && apt-get install build-essential -y && apt-get update
	fi
}

install(){
	check_system
	check_root
	directory

	apt-get update && gcc && apt-get install zip -y
	wget https://raw.githubusercontent.com/nanqinlang/dnsmasq/master/dnsmasq-2.75.zip && unzip dnsmasq-2.75.zip
	make && make install
	rm -rf /home/dnsmasq-installation

	config
	start
}

config(){
	[[ ! -d /home/dnsmasq/conf ]] && mkdir -p /home/dnsmasq/conf
	cd /home/dnsmasq/conf
	echo -e "
	port=5353
	server=208.67.222.222#5353
	cache-size=20170922\c" > config.conf
}

start(){
	check_system
	check_root
	cd /home/dnsmasq/sbin && ./dnsmasq --conf-file=/home/dnsmasq/conf/config.conf
	status
}

status(){
	pid=`ps -ef|grep "dnsmasq"|grep -v "grep"|awk '{print $2}'`
	if [[ -z ${pid} ]]; then
		echo -e "${Error} dnsmasq not running, please check!" && exit 1
		else echo -e "${Info} dnsmasq is running"
	fi
}

uninstall(){
	killall dnsmasq && rm -rf /home/dnsmasq
	echo -e "${Info} uninstall dnsmasq finished"
}

command=$1
if [[ "${command}" = "" ]]; then
	echo -e "${Info}command not found, usage: ${Green_font}{ install | start | uninstall }${Font_suffix}" && exit 0
else
	command=$1
fi
case "${command}" in
	 install)
	 install 2>&1
	 ;;
	 start)
	 start 2>&1
	 ;;
	 uninstall)
	 uninstall 2>&1
	 ;;
esac

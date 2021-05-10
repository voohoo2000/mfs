#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#===========================================================================================
#  System Tested: CentOS 8+, Debian 10+, Ubuntu 19+, UOS 20+(开发模式), Kylin V4, Kylin V10+
#  Description: my favorite shell
#  License: MIT License
#===========================================================================================

sh_ver="0.1.2"

GREEN="\033[32m" && RED="\033[31;5m" && RESET="\033[0m"
INFO="${GREEN}[信息]${RESET}"
ERROR="${RED}[错误]${RESET}"

check_sudo(){
	sudo -v
	case $? in
		0)
			MSG_SUDO=""
			;;
		*)
			MSG_SUDO="\n${ERROR} ${GREEN}$(logname)${RESET}不在sudo组，请选择[${GREEN}9${RESET}]输入root密码后重新登录运行此脚本!\n"
			;;
	esac
}

set_source_mirror(){
	echo -e "${INFO}: set_source_mirror"
	case $release in
		ubuntu)
				sudo sed -e "s/\/\/\.*.ubuntu.com/\/\/mirrors.aliyun.com/g" \
				 -i.bak /etc/apt/sources.list
				sudo sed -e "s/\/\/\.*.ubuntu.com/\/\/mirrors.aliyun.com/g" \
				 -i.bak /etc/apt/sources.list.d/*.*
				sudo apt update
				sudo apt upgrade -y
				;;
		debian)
				sudo sed -e "s/^deb cdrom/# deb cdrom/g" \
				 -e "s/\/\/.*.debian.org/\/\/mirrors.aliyun.com/g" \
				 -i.bak /etc/apt/sources.list
				sudo sed -e "s/^deb cdrom/# deb cdrom/g" \
				 -e "s/\/\/.*.debian.org/\/\/mirrors.aliyun.com/g" \
				 -i.bak /etc/apt/sources.list.d/*.*
				sudo apt update
				sudo apt upgrade -y
				;;
		centos)
				sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org|baseurl=http://mirrors.aliyun.com|g' \
         -i.bak /etc/yum.repos.d/CentOS-*.repo
				sudo yum clean all
				sudo yum makecache
				;;
		NeoKylin)
				sudo yum clean all
				sudo yum makecache
				;;
	esac

	echo -e "${INFO}: speedup github"
	GITHUB_COM_IP="140.82.114.3"
	GITHUB_COM="github.com"
	GITHUB_FST_ID="199.232.69.194"
	GITHUB_FST="github.global.ssl.fastly.net"

	if [ `sed -n "/$GITHUB_COM/p" /etc/hosts | wc -l` -eq 0 ]; then
		echo -e "$GITHUB_COM_IP\t$GITHUB_COM" | sudo tee -a /etc/hosts
	else
		sudo sed -i "s/.*$GITHUB_COM/$GITHUB_COM_IP\t$GITHUB_COM/g" /etc/hosts
	fi
	if [ `sed -n "/$GITHUB_FST/p" /etc/hosts | wc -l` -eq 0 ]; then
		echo -e "$a$GITHUB_FST_ID\t$GITHUB_FST" | sudo tee -a /etc/hosts
	else
		sudo sed -i "s/.*$GITHUB_FST/$GITHUB_FST_ID\t$GITHUB_FST/g" /etc/hosts
	fi

}

install_tldr(){
	echo -e "${INFO}: install_tldr"
	case $release in
		ubuntu|debian)
				sudo apt install npm -y
				sudo npm install -g tldr
				;;
		centos|NeoKylin)
				sudo yum install npm -y
				sudo npm install -g tldr
				;;
	esac
}

install_zsh_plugins(){
	echo -e "${INFO}: install_zsh_plugins"
	case $release in
		ubuntu|debian)
				sudo apt install git -y
				sudo apt install wget -y
				sudo apt install curl -y
				sudo apt install python -y
				sudo apt install zsh -y
				#avoid interactive
				export SHELL=/bin/zsh
				sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | grep -v 'exec zsh')"
				#sh -c "$(wget -qO- https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh | grep -v 'exec zsh')"
				;;
		centos)
				sudo yum install git -y
				sudo yum install wget -y
				sudo yum install curl -y
				sudo yum install zsh -y
				#fix issue on centos8
				[ ! -f /usr/bin/python ] && [ -f /usr/bin/python3 ] && sudo ln -s /usr/bin/python3 /usr/bin/python
				[ ! -f /usr/bin/python ] && [ -f /usr/bin/python2 ] && sudo ln -s /usr/bin/python2 /usr/bin/python
				#avoid interactive
				export SHELL=/bin/zsh
				sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | grep -v 'exec zsh')"
				#sh -c "$(wget -qO- https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh | grep -v 'exec zsh')"
				;;
		NeoKylin)
				return
				;;
	esac

	#cp $HOME/.oh-my-zsh/templates/zshrc.zsh-template $HOME/.zshrc
	
	if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
		git clone git://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
		#echo "source $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> $HOME/.zshrc
	fi

	if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
		#echo "source $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> $HOME/.zshrc
	fi

	if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/autojump" ]; then
		git clone https://github.com/wting/autojump.git $HOME/.oh-my-zsh/custom/plugins/autojump
		cd $HOME/.oh-my-zsh/custom/plugins/autojump
		./install.py
		cd $HOME
		#echo "[[ -s $HOME/.autojump/etc/profile.d/autojump.sh ]] && source $HOME/.autojump/etc/profile.d/autojump.sh" >> $HOME/.zshrc
	fi

	sed -i 's/^ZSH_THEME="[[:print:]]*"/ZSH_THEME="ys"/g' $HOME/.zshrc
	sed -i 's/^plugins=([[:print:]]*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting autojump)/g' $HOME/.zshrc
	
	chsh -s /bin/zsh
}

install_vimrc(){
	echo -e "${INFO}: install_vimrc"
	case $release in
		ubuntu|debian)
				sudo apt install curl git gcc make vim -y
				;;
		centos|NeoKylin)
				sudo yum install curl git gcc make vim -y
				;;
	esac
	
	git clone --depth=1 https://github.com/amix/vimrc.git $HOME/.vim_runtime
	sh $HOME/.vim_runtime/install_awesome_vimrc.sh
	echo "let g:snipMate = { 'snippet_version' : 1 }" >> $HOME/.vimrc
}

install_all(){
	set_source_mirror
	install_zsh_plugins
	install_vimrc
	install_tldr
	run_zsh
}

uninstall_all(){

	if [ -d "$HOME/.oh-my-zsh" ]; then
		read -p " 您需要删除zsh及插件吗? [Y/n]" opt
		case $opt in
			y*|Y*|"") 
				sh -c "$(wget -qO- https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/uninstall.sh)" 
				;;
		esac
	fi

	if [ -d "$HOME/.vim_runtime" ]; then
		read -p " 您需要删除The Ultimate Vim Configuration(vimrc)吗? [Y/n]" opt
		case $opt in
			y*|Y*|"") 
				rm -rf $HOME/.vim_runtime
				sed -i '/vim_runtime/d' $HOME/.vimrc
				sed -i '/snippet_version/d' $HOME/.vimrc
				;;
		esac
	fi
}

run_zsh()
{
	if [ -f /bin/zsh ]; then
		exec zsh -l
	fi
}

add_user_to_sudo_group(){
 	su - root -c "usermod -a -G sudo $(logname) && pkill -kill -u $(logname)"
}

start_menu(){
clear
echo -e " Linux环境配置一键脚本 ${GREEN}[v${sh_ver}]${RESET}

———————————————————————————————安装脚本———————————————————————————————
 ${MSG_SUDO}
 ${GREEN}1.${RESET} 全部安装
 ${GREEN}2.${RESET} 更改国内镜像源(debian, ubuntu, centos)，加速Github
 ${GREEN}3.${RESET} 安装zsh及插件(autosuggestions, autojump, zsh-syntax-highlighting)
 ${GREEN}4.${RESET} 安装tldr插件(命令帮助)
 ${GREEN}5.${RESET} 安装vim及vimrc
 ${GREEN}6.${RESET} 卸载插件(oh-my-zsh, vimrc)

———————————————————————————————系统管理———————————————————————————————

 ${GREEN}9.${RESET} 加入${GREEN}$(logname)${RESET}到sudo组后重新登录 (需要Root权限)
 ${GREEN}0.${RESET} 退出脚本

——————————————————————————————————————————————————————————————————————"

echo
read -p " 请输入数字 [1-6, 9, 0]:" num
case "$num" in
	1)
	install_all
	;;
	2)
	set_source_mirror
	;;
	3)
	install_zsh_plugins
	;;
	4)
	install_tldr
	;;
	5)
	install_vimrc
	;;
	6)
	uninstall_all
	;;
  9)
	add_user_to_sudo_group
	;;
	0)
	exit 0
	;;
	*)
	clear
	echo -e "${ERROR}:请输入正确数字 [1-6, 9, 0]"
	sleep 5s
	start_menu
	;;
esac
}

check_sys(){
	if [[ -f /etc/redhat-release ]]; then
					release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
					release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu|UnionTech"; then
					release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos"; then
					release="centos"
	elif cat /etc/issue | grep -q -E -i "NeoKylin"; then
					release="NeoKylin"
	elif cat /proc/version | grep -q -E -i "debian"; then
					release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu|deepin"; then
					release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos"; then
					release="centos"
	elif cat /proc/version | grep -q -E -i "NeoKylin"; then
				release="NeoKylin"
	fi
	echo -e "${INFO}: check_sys: $release"
}

check_version(){
	if [[ -s /etc/redhat-release ]]; then
		version=`grep -oE  "[0-9.]+" /etc/redhat-release | cut -d . -f 1`
	else
		version=`grep -oE  "[0-9.]+" /etc/issue | cut -d . -f 1`
	fi
	bit=`uname -m`
	if [[ ${bit} = "x86_64" ]]; then
		bit="x64"
	else
		bit="x32"
	fi
	echo -e "${INFO}: check_version: $version, $bit"
}

check_sys
check_version
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && [[ ${release} != "NeoKylin" ]]&& echo -e "${ERROR} 本脚本不支持当前系统 ${release} !" && exit 1
check_sudo
start_menu
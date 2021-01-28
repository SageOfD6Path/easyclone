#!/usr/bin/env bash
#=============================================================
# https://github.com/xd003/clone
# File Name: setup.sh
# Author: xd003
# Description: Installing prerequisites for clone script
# System Supported: Arch , Ubuntu/Debian , Fedora & Termux
#=============================================================

cecho() {
        local code="\033["
        case "$1" in
                black  | bk) color="${code}0;30m";;
                red    |  r) color="${code}1;31m";;
                green  |  g) color="${code}1;32m";;
                yellow |  y) color="${code}1;33m";;
                blue   |  b) color="${code}1;34m";;
                purple |  p) color="${code}1;35m";;
                cyan   |  c) color="${code}1;36m";;
                gray   | gr) color="${code}0;37m";;
                *) local text="$1"
        esac
        [ -z "$text" ] && local text="$color$2${code}0m"
        echo -e "$text"
}

#Variables 
version=v0.4.1
arch="$(uname -m)"
ehome="$(echo $HOME)"
epac="$(which pacman)"
eapt="$(which apt)"
ednf="$(which dnf)"
eclone="$(which clone)"
conf="$HOME/easyclone/rc.conf"

# Detecting the OS and installing required dependencies
echo
cecho r "Detecting the OS and installing required dependencies"
if [ "$ehome" == "/data/data/com.termux/files/home" ]; then
    echo "Termux detected" && \
    pkg install -y unzip git wget
elif [ "$epac" == "/usr/bin/pacman" ]; then
    echo "Arch based OS detected" && \
    sudo pacman --noconfirm -S unzip git wget
elif [ "$eapt" == "/usr/bin/apt" ]; then 
    echo "Ubuntu based OS detected" && \
    sudo apt install -y unzip git wget
elif [ "$ednf" == "/usr/bin/dnf" ]; then
    echo "Fedora based OS detected"
    sudo dnf install -y unzip git wget
fi
cecho b "All dependencies were installed successfully"

# Detecting the linux kernel architecture
echo
cecho r "Detecting the kernel architecture"
if [ "$arch" == "arm64" ] || [ "$arch" == "aarch64" ] ; then
  arch=arm64
elif [ "$arch" == "x86_64" ] ; then
  arch=amd64
fi

# Removing old Files and pulling new ones
echo
cecho r "Deleting old files & pulling new ones from github"
sudo rm -rf $(which fclone)
rm -rf $HOME/.easyclone
mkdir $HOME/.easyclone
mkdir $HOME/tmp
git clone https://github.com/xd003/easyclone $HOME/tmp
wget -c -t 0 --timeout=60 --waitretry=60 https://github.com/mawaya/rclone/releases/download/fclone-$version/fclone-$version-linux-$arch.zip -O $HOME/tmp/fclone.zip
unzip -q $HOME/tmp/fclone.zip -d $HOME/tmp
mv $HOME/tmp/clone $HOME/.easyclone
mv $HOME/tmp/fclone-$version-linux-$arch/fclone $HOME/.easyclone
chmod u+x $HOME/.easyclone/clone
chmod u+x $HOME/.easyclone/fclone
rm -rf $HOME/tmp
cecho b "Easyclone script & fclone successfully updated"

# Adding the clone script & fclone executable to path
echo
cecho r "Adding the clone script & fclone executable to path"
if [ "$eclone" == "$HOME/.easyclone/clone" ]; then
    cecho b "Easyclone Script pre exists in path //Skipping"
else
    if [ -f "$HOME/.bashrc" ]; then
        echo 'export PATH="$PATH:$HOME/.easyclone"' >> $HOME/.bashrc && \
        cecho b "Successfully added the necessary files to path"
        source ~/.bashrc
    elif [ -f "$HOME/.zshrc" ]; then
        echo 'export PATH="$PATH:$HOME/.easyclone"' >> $HOME/.zshrc && \
        cecho b "Successfully added the necessary files to path"
        source ~/.zshrc
    else
        touch $HOME/.bashrc && \
        echo 'export PATH="$PATH:$HOME/.easyclone"' >> $HOME/.bashrc && \
        cecho b "Successfully added the necessary files to path"
        source ~/.bashrc
    fi
fi

# Pulling the accounts folder containing service accounts from github 
echo
cecho r "Pulling the accounts folder containing service accounts from github"
if [ -d "$HOME/easyclone/accounts" ] && [ -f "$HOME/easyclone/accounts/1.json" ]; then
    cecho b "Accounts folder already existing //Skipping"
else
    mkdir -p $HOME/easyclone/accounts
    echo && cecho r "Downloading the service accounts from your private repo"
    read -e -p "Input your github username : " username
    read -e -p "Input your github password : " password
    git clone https://"$username":"$password"@github.com/"$username"/accounts $HOME/easyclone/accounts
    cecho b "Service accounts were added Successfully"
fi

# Creating the rclone.conf with appropriate info
echo
cecho r "Generating rclone config to be used"
if grep -q "$HOME/easyclone/accounts/1.json" $conf; then
    cecho b "gd remote to be generated by easyclone pre exists in rc.conf //Skipping"
else
    read -e -p "Input your client_id : " client
    read -e -p "Input your client_secret : " secret
    touch $conf
    echo "[gd]" >> $conf
    echo "type = drive" >> $conf
    eval echo "client_id = $client" >> $conf
    eval echo "client_secret = $secret" >> $conf
    echo "scope = drive" >> $conf
    eval echo "service_account_file = $HOME/easyclone/accounts/1.json" >> $conf
    eval echo "service_account_file_path = $HOME/easyclone/accounts/" >> $conf
    cecho b "Successfully Generated the config with appropriate info"
fi

echo
cecho g "Entering clone will always start the script henceforth"

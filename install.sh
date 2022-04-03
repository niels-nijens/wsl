#!/bin/bash

function updatePackages() {
  echo "Updating system packages..."
  sudo apt-get update
  sudo apt-get upgrade -y
}

function installDevelopmentUtilities() {
  echo "Installing common development utilities..."
  sudo apt-get install -y \
    git \
    build-essential
}

function configureGit() {
  echo "Configuring git..."
  echo -n "" >> ~/.gitignore
  git config --global --add core.autocrlf input
  git config --global --path --add core.excludesfile "$HOME/.gitignore"
  git config --global --add push.default simple
  git config --global --add credential.helper "cache --timeout=432000"
}

function installSystemdGenie() {
  echo "Installing Systemd genie..."
  installSystemdGenieSource

  sudo apt-get update
  sudo apt install -y systemd-genie

  configureSystemd
}

function installSystemdGenieSource() {
  sudo wget -qO /etc/apt/trusted.gpg.d/wsl-transdebian.gpg https://arkane-systems.github.io/wsl-transdebian/apt/wsl-transdebian.gpg
  sudo chmod a+r /etc/apt/trusted.gpg.d/wsl-transdebian.gpg
  if [ ! -f /etc/apt/sources.list.d/wsl-transdebian.list ]; then
    sudo su -c "cat << EOF > /etc/apt/sources.list.d/wsl-transdebian.list
deb https://arkane-systems.github.io/wsl-transdebian/apt/ focal main
deb-src https://arkane-systems.github.io/wsl-transdebian/apt/ focal main
EOF"
  fi
}

function configureSystemd() {
  sudo systemctl set-default multi-user.target
  sudo systemctl disable multipathd.service
  sudo systemctl mask systemd-modules-load.service
}

function createSshKey() {
  echo "Creating new SSH key..."
  ssh-keygen -t ed25519
}

function installBashInit() {
  echo "Installing bash init script..."
  mkdir -p ~/bin/
  wget -qO ~/bin/bash-init.sh https://raw.githubusercontent.com/niels-nijens/wsl/main/bash-init.sh
  chmod +x ~/bin/bash-init.sh
  echo "source ~/bin/bash-init.sh" >> ~/.bashrc
}

function promptInstallDockerEngineAndCompose() {
  echo "Install Docker Engine and Docker Compose?"
  select prompt in "Yes" "No" "Exit"; do
    case $prompt in
      Yes ) installDockerEngineAndCompose; break;;
      No ) break;;
      Exit ) exit;;
    esac
  done
}

function installDockerEngineAndCompose() {
  sudo apt-get install -y \
      ca-certificates \
      curl \
      gnupg \
      lsb-release \
      uidmap
  bash <(curl -fsSL https://get.docker.com)
  sudo groupadd docker
  sudo usermod -aG docker $USER

  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
}

function promptInstallJetbrainsToolbox() {
  echo "Install Jetbrains Toolbox?"
  select prompt in "Yes" "No" "Exit"; do
    case $prompt in
      Yes ) installJetbrainsToolbox; break;;
      No ) break;;
      Exit ) exit;;
    esac
  done
}

function installJetbrainsToolbox() {
  echo "Installing Nautilus for Jetbrains Toolbox dependencies..."
  sudo apt-get install -y nautilus
  echo "Installing Jetbrains Toolbox..."
  wget -qO /tmp/jetbrains-toolbox-1.23.11680.tar.gz https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.23.11680.tar.gz
  mkdir -p ~/.local/share/JetBrains/Toolbox/
  cd ~/.local/share/JetBrains/Toolbox/
  tar -xvzf /tmp/jetbrains-toolbox-1.23.11680.tar.gz
  mv ~/.local/share/JetBrains/Toolbox/jetbrains-toolbox-1.23.11680 ~/.local/share/JetBrains/Toolbox/bin

  echo "/.idea/" >> ~/.gitignore
}

function promptRunJetbrainsToolbox() {
  echo "Run Jetbrains Toolbox?"
  select prompt in "Yes" "No" "Exit"; do
    case $prompt in
      Yes ) runJetbrainsToolbox; break;;
      No ) break;;
      Exit ) exit;;
    esac
  done
}

function runJetbrainsToolbox() {
  cmd="$HOME/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox"
  $cmd &
}

function promptInstallNodeJsAndYarn() {
  echo "Install NodeJS and Yarn?"
  select prompt in "Yes" "No" "Exit"; do
    case $prompt in
      Yes ) installNodeJsAndYarn; break;;
      No ) break;;
      Exit ) exit;;
    esac
  done
}

function installNodeJsAndYarn() {
  echo "Installing NodeJS ..."
  curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  sudo apt-get install -y nodejs

  echo "Installing Yarn..."
  corepack enable
}

updatePackages
installDevelopmentUtilities
installSystemdGenie
createSshKey
installBashInit
promptInstallDockerEngineAndCompose
promptInstallJetbrainsToolbox
promptRunJetbrainsToolbox
promptInstallNodeJsAndYarn

#!/bin/bash

# Global Vars
DOWNLOAD_PATH=$HOME/Downloads/tmp
OS_VERSION=24.04
VERSION=0.2.23

# Fetch all the named args
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

  shift
done

clear 

echo "----------------------------------------------------"
echo "Welcome to Nubuntu $OS_VERSION (v$VERSION)"
echo "=> The following will be installed:"
echo " -> rpms: $rpms"
echo " -> flatpaks: $flatpaks"
if [ -n "$dnf_install" ]; then
  echo "=> the following apt install(s) will be invoked"
  echo " -> $dnf_install"
fi
if [ -n "$dnf_remove" ]; then
  echo "=> the following apt remove(s) will be invoked"
  echo " -> $dnf_remove"
fi
if [[ $debloat == "yes" ]]; then
  # echo "=> snap packages will be removed"
fi
if [[ $neaten == "yes" ]]; then
  echo "=> the shell will also be neatened"
fi
if [[ $theme == "dark" ]]; then
  echo "=> dark theme will be set"
fi
echo "----------------------------------------------------"


echo "*****************************************************"
echo "Upgrading and Updating Installing and Removing"
echo "*****************************************************"
sudo dnf update -yq

if [ -n "$dnf_install" ]; then
  IFS=',' read -ra app_list <<< "$dnf_install"
  for app in "${app_list[@]}"; do
      sudo dnf install -yq $app
  done
fi

if [ -n "$dnf_remove" ]; then
  IFS=',' read -ra app_list <<< "$dnf_remove"
  for app in "${app_list[@]}"; do
      sudo dnf remove -yq $app
  done
fi


if [[ $debloat == "yes" ]]; then
  echo "*****************************************************"
  echo "Debloating"
  echo "*****************************************************"

  sudo dnf remove -yq gnome-user-docs yelp

fi


echo "*****************************************************"
echo "Installing essential RPM applications"
echo "*****************************************************"
mkdir $DOWNLOAD_PATH

# INSTALL: VS CODE
if [[ $debs =~ "vscode" ]]; then
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
  sudo dnf check-update
  sudo dnf install -yq code
fi

# INSTALL: Chrome
if [[ $debs =~ "chrome" ]]; then
  sudo dnf install -yq google-chrome-stable
fi

# INSTALL: dbeaver
if [[ $debs =~ "dbeaver" ]]; then
  wget -c https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm -O $DOWNLOAD_PATH/dbeaver.rpm
  sudo dnf install -yq $DOWNLOAD_PATH/dbeaver.rpm
fi

# INSTALL: docker
if [[ $debs =~ "docker" ]]; then
sudo dnf remove -yq docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
  sudo dnf -yq install dnf-plugins-core
  sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  sudo dnf install -yq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker $USER
fi


echo "*****************************************************"
echo "Installing flatpak applications"
echo "*****************************************************"

if [ -n "$flatpaks" ]; then
  sudo apt -yq install flatpak
  sudo apt -yq install gnome-software-plugin-flatpak
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo


  IFS=',' read -ra app_list <<< "$flatpaks"
  for app in "${app_list[@]}"; do
      sudo flatpak install --noninteractive -y $app
  done
fi


if [[ $neaten == "yes" ]]; then
  echo "*****************************************************"
  echo "Neatening up the shell"
  echo "*****************************************************"


  gsettings set org.gnome.shell favorite-apps "[ 'google-chrome.desktop', 'com.bitwarden.desktop.desktop', 'org.gnome.Nautilus.desktop' ]"

  add_gnome_menu_folders() {
    folder_name=$1
    readable_name=$2
    apps=$3

    gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/$folder_name/ name "$readable_name"
    gsettings set org.gnome.desktop.app-folders.folder:/org/gnome/desktop/app-folders/folders/$folder_name/ apps "[ $apps ]"

  }

  add_gnome_menu_folders "system" "🖥️ System" "'org.gnome.Logs.desktop', 'org.gnome.PowerStats.desktop', 'org.gnome.SystemMonitor.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.Tecla.desktop', 'org.gnome.baobab.desktop', 'org.gnome.seahorse.Application.desktop', 'org.gnome.Settings.desktop', 'org.gnome.OnlineAccounts.OAuth2.desktop', 'software-properties-drivers', 'software-properties-gtk', 'update-manager', 'nm-connection-editor', 'gnome-session-properties', 'gnome-language-selector', 'gnome-session-properties.desktop', 'nm-connection-editor.desktop', 'gnome-language-selector.desktop', 'update-manager.desktop', 'software-properties-gtk.desktop', 'software-properties-drivers.desktop', 'htop.desktop'"

  add_gnome_menu_folders "accessories" "🖊️ Accessories" "'org.gnome.font-viewer.desktop', 'org.gnome.clocks.desktop', 'org.gnome.Characters.desktop', 'org.gnome.Calculator.desktop', 'org.gnome.eog.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Evince', 'org.gnome.Evince.desktop', 'org.gnome.Software.desktop'"

  add_gnome_menu_folders "dev" "⚒️ Dev" "'code.desktop', 'dbeaver-ce.desktop'"

  gsettings set org.gnome.desktop.app-folders folder-children "[ 'accessories', 'system', 'dev' ]"

fi

if [[ $theme == "dark" ]]; then
  mkdir -p $HOME/Pictures/Wallpapers
  # wallpaper credit : https://wallhaven.cc/w/g82vvq
  wget https://raw.githubusercontent.com/calobyte/nubuntu/refs/heads/main/wallpapers/24.04/dark.jpg -O $HOME/Pictures/Wallpapers/dark.jpeg
  gsettings set org.gnome.desktop.background picture-uri-dark file://$HOME/Pictures/Wallpapers/dark.jpeg

  wget https://raw.githubusercontent.com/calobyte/nubuntu/refs/heads/main/fonts/jetbrains-fonts.tar -O $DOWNLOAD_PATH/jetbrains-fonts.tar
  sudo tar -xf $DOWNLOAD_PATH/jetbrains-fonts.tar -C /usr/share/fonts/truetype/ --wildcards "*.ttf"
  fc-cache -f

  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-blue-dark'
  gsettings set org.gnome.desktop.interface icon-theme 'Yaru-blue'
  gsettings set org.gnome.desktop.interface show-battery-percentage true
  gsettings set org.gnome.desktop.interface enable-hot-corners true
  gsettings set org.gnome.desktop.interface monospace-font-name 'Jetbrains Mono 13'

  # update flatpak theme to dark
  sudo flatpak install  --noninteractive -y org.gtk.Gtk3theme.Adwaita-dark
  sudo flatpak override --env=GTK_THEME=Adwaita-dark
fi

sudo apt autoremove -yq
rm -rf $DOWNLOAD_PATH


echo "*****************************************************"
echo "Complete, please logout/reboot to see flatpaks"
echo "*****************************************************"
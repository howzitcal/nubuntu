# Welcome to nubuntu


**nubuntu** is an easy way to debloat and customize your Vanilla Ubuntu Distro with one script. This project aims to make setting up an Ubuntu distro quick and painless, automating the boring tasks so that you can get back to being _productive!_


## Features
- Removes `snap` and all snap packages via `--debloat`
- Installs "common applications" via `--debs "[packages]"`. Only `vscode,chrome,docker,dbeaver` are available.
- Installs APT packages via `--apt_install "[packages]"`
- Removed APT packages via `--apt_remove "[package]"`
- Installs `flatpak` and flatpaks via `--flatpaks "[packages]"`
- Sets up a dark-blue theme with a wallpaper and Jetbrains mono font as well as neatens up the gnome menu via `--theme "dark"`


## Notes
- The idea is to install as many APT packages as possible and only use flatpak when it's necessary
- Help wanted, if you see ways to make this better, please submit a PR

## Current Supported Versions of Ubuntu
- 24.04

## Before nubuntu
| Desktop | Menu |
|:---|:---|
|![image of vanilla desktop](https://raw.githubusercontent.com/howzitcal/nubuntu/refs/heads/main/images/before-desktop.png)|![image of vanilla menu](https://raw.githubusercontent.com/howzitcal/nubuntu/refs/heads/main/images/before-gnome-menu.png)|

## After nubuntu
| Desktop | Menu |
|:---|:---|
|![image of vanilla desktop](https://raw.githubusercontent.com/howzitcal/nubuntu/refs/heads/main/images/after-desktop.png)|![image of vanilla menu](https://raw.githubusercontent.com/howzitcal/nubuntu/refs/heads/main/images/after-gnome-menu.png)|

## Ubuntu 24.04 Example:
```bash
curl -o- https://raw.githubusercontent.com/howzitcal/nubuntu/refs/heads/main/24.04.sh | bash -s -- \
    --debs "vscode,chrome,docker,dbeaver" \
    --flatpaks "com.bitwarden.desktop" \
    --debloat "yes" \
    --neaten "yes" \
    --apt_install "htop,aria2" \
    --theme "dark"
```

## Command Structure (Add your own arguments)
```bash
curl -o- https://raw.githubusercontent.com/howzitcal/nubuntu/refs/heads/main/24.04.sh | bash -s -- \
    --debs "[package,...]" \
    --flatpaks "[com.package, ...]" \
    --debloat "[yes/no]" \
    --neaten "[yes/no]" \
    --apt_install "[package,...]" \
    --apt_remove "[package,...]" \
    --theme "[dark]"
```

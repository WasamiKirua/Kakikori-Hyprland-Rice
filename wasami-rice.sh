#!/bin/bash

prep_stage=(
    brightnessctl
    dunst
    eww
    grimblast-git
    gegl
    inotify-tools
    ivm
    imagemagick
    light
    libpng
    libdrm
    libxkbcommon
    pamixer
    pixman
    qt5-wayland 
    qt6-wayland
    ranger
    rofi
    sddm-sugar-candy-git
    swaybg
    swaylock-effects
    swww
    swappy
    kitty
    wayland
    wttrbar
    wlroots
    wf-recorder
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-wlr
    xdg-user-dirs
    xorg-xwayland
)

themes_stage=(
    whitesur-icon-theme-git 
    whitesur-cursor-theme-git 
    whitesur-gtk-theme-git
    papirus-icon-theme
    otf-font-awesome
    otf-font-awesome-4
)

software_stage=(
    visual-studio-code-bin
    firefox-developer-edition 
    discord 
    betterdiscordctl 
    betterdiscord-git 
    telegram-desktop
    python-pywalfox
    #python-pywal 
    pywal-discord-git
    pipes.sh
    wal-telegram-git 
    spotify
    spicetify-cli
    tty-clock 
    pipes.sh
    cava 
    vlc
    chromium
    imv
)

other_toys=(
    gedit
    htop 
    libcanberra
    mousepad
    neofetch 
    neovim 
    networkmanager-openvpn
    playerctl
    python 
    ripgrep
    nodejs
    npm
    python-pip 
    python-pillow
    swaybg
    tmux 
    zsh 
    waybar
    docker
    pyenv
    bleachbit-cli
    tk


)

file_manager=(
    file-roller
    gvfs 
    gvfs-smb
    sshfs
    thunar 
    thunar-volman 
    tumbler 
    thunar-archive-plugin 
)

for str in ${myArray[@]}; do
    echo $str
done

### Check if ROOT
if [[ $EUID -eq 0 ]]; then
	echo "No ROOT Please Exiting!"
	exit 1
fi

### Set messages's color 
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
ORANGE=$(tput setaf 166)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

### Set LOG
LOG="install-$(date +%d-%H%M%S).log"

### Print logo.txt
tput setaf 5; cat logo.txt
printf "\n"
printf "\n"
printf "\n"

###Print warning message
printf "\n${WARN} For Arch only.\n"
printf "\n${NOTE} This script is made to work best on a fresh Arch installed system.\n"
printf "\n${NOTE} I use Audio - pipewire, Profile - minimal, Boot Loader - systemd-bootctl and NetworkManager\n"
printf "${ORANGE}$(tput smso)This script has been tested with GTX 1070 as well RTX 2070$(tput rmso)\n"
sleep 2
printf "\n"
printf "\n"

### Proceed
read -n1 -rep "${CAT} Shall we proceed with installation (y/n) " PROCEED
    echo
if [[ $PROCEED =~ ^[Yy]$ ]]; then
    printf "\n%s  Alright.....LETS BEGIN!.\n" "${OK}"
else
    printf "\n%s  NO changes made to your system. Cheers\n" "${NOTE}"
    exit
fi

### Check for AUR helper and install if not found
ISAUR=$(command -v yay || command -v paru)

if [ -n "$ISAUR" ]; then
    printf "\n%s - AUR helper was located, moving on.\n" "${OK}"
else 
    printf "\n%s - AUR helper was NOT located\n" "$WARN"

    while true; do
        read -rp "${CAT} Which AUR helper do you want to use, yay or paru? Enter 'y' or 'p': " choice 
        case "$choice" in
            y|Y)
                printf "\n%s - Installing yay from AUR\n" "${NOTE}"
                git clone https://aur.archlinux.org/yay-bin.git || { printf "%s - Failed to clone yay from AUR\n" "${ERROR}"; exit 1; }
                cd yay-bin || { printf "%s - Failed to enter yay-bin directory\n" "${ERROR}"; exit 1; }
                makepkg -si --noconfirm 2>&1 | tee -a "$LOG" || { printf "%s - Failed to install yay from AUR\n" "${ERROR}"; exit 1; }
                cd ..
                break
                ;;
            p|P)
                printf "\n%s - Installing paru from AUR\n" "${NOTE}"
                git clone https://aur.archlinux.org/paru-bin.git || { printf "%s - Failed to clone paru from AUR\n" "${ERROR}"; exit 1; }
                cd paru-bin || { printf "%s - Failed to enter paru-bin directory\n" "${ERROR}"; exit 1; }
                makepkg -si --noconfirm 2>&1 | tee -a "$LOG" || { printf "%s - Failed to install paru from AUR\n" "${ERROR}"; exit 1; }
                cd ..
                break
                ;;
            *)
                printf "%s - Invalid choice. Please enter 'y' or 'p'\n" "${ERROR}"
                continue
                ;;
        esac
    done
fi

clear

### Update system
printf "\n%s - Performing a full system update \n" "${NOTE}"
ISAUR=$(command -v yay || command -v paru)

$ISAUR -Syu --noconfirm 2>&1 | tee -a "$LOG" || { printf "%s - Failed to update system\n" "${ERROR}"; exit 1; }

clear

### Set the script to exit on error
set -e

### Function for installing packages
install_package() {
    # checking if package is already installed
    if $ISAUR -Q "$1" &>> /dev/null ; then
        echo -e "${OK} $1 is already installed. skipping..."
    else
        # package not installed
        echo -e "${NOTE} installing $1 ..."
        $ISAUR -S --noconfirm "$1" 2>&1 | tee -a "$LOG"
        # making sure package installed
        if $ISAUR -Q "$1" &>> /dev/null ; then
            echo -e "\e[1A\e[K${OK} $1 was installed."
        else
            # something is missing, exitting to review log
            echo -e "\e[1A\e[K${ERROR} $1 failed to install :(, please check the install.log"
            exit 1
        fi
    fi
}

### Function to print error messages
print_error() {
    printf " %s%s\n" "${ERROR}" "$1" "$NC" 2>&1 | tee -a "$LOG"
}

### Function to print success messages
print_success() {
    printf "%s%s%s\n" "${OK}" "$1" "$NC" 2>&1 | tee -a "$LOG"
}

### Automatic detection of Nvidia-GPU is present in your system
if ! lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    printf "${YELLOW} No NVIDIA GPU detected in your system. Installing Hyprland without Nvidia support..."
    sleep 1
    for HYP in hyprland-git; do
        install_package "$HYP" 2>&1 | tee -a $LOG
    done
else
    printf "${YELLOW} NVIDIA GPU Detected. Installing Hyprland with NVIDIA support...\n"
    sleep 1
    install_package "hyprland-git" 2>&1 | tee -a $LOG
    printf "\n%s - Installin additional NVIDIA packages \n" "${NOTE}"
    echo
    for NVIDIA in linux-headers nvidia-dkms nvidia-settings nvidia-utils libva libva-nvidia-driver-git; do
        install_package "$NVIDIA" 2>&1 | tee -a $LOG
    done
    
    #check if the nvidia modules are already added in mkinitcpio.conf and add if not
    if grep -qE '^MODULES=.*nvidia. *nvidia_modeset.*nvidia_uvm.*nvidia_drm' /etc/mkinitcpio.conf; then
        echo "Nvidia modules already included in /etc/mkinitcpio.conf" 2>&1 | tee -a $LOG
    else
        sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf 2>&1 | tee -a $LOG
        echo "Nvidia modules added in /etc/mkinitcpio.conf"
    fi
    sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img 2>&1 | tee -a $LOG
    printf "\n"   
    printf "\n"
    printf "\n"
    
    # preparing exec.conf to enable env = WLR_NO_HARDWARE_CURSORS,1 so it will be ready once config files copied
    sed -i '1,2s/#//' dotfiles/.congif/hypr/hyprland.conf
    
    # Additional Nvidia steps
    NVEA="/etc/modprobe.d/nvidia.conf"
    if [ -f "$NVEA" ]; then
        printf "${OK} Seems like nvidia-drm modeset=1 is already added in your system..moving on.\n"
        printf "\n"
    else
        printf "\n"
        printf "${YELLOW} Adding options to $NVEA..."
        sudo echo -e "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf 2>&1 | tee -a $LOG
        printf "\n"  
    fi
fi

clear

### Packages installation
printf "\n%s - Installing other necessary packages.... \n" "${NOTE}"
for SOFTWR in ${prep_stage[@]}; do
        install_package $SOFTWR 2>&1 | tee -a "$LOG"
        if [ $? -ne 0 ]; then
            echo -e "\e[1A\e[K${ERROR} - $PKG1 install had failed, please check the install.log"
            exit 1
        fi
done

for FONT in ${themes_stage[@]}; do
        install_package $FONT 2>&1 | tee -a "$LOG"
        if [ $? -ne 0 ]; then
            echo -e "\e[1A\e[K${ERROR} - $FONT install had failed, please check the install.log"
            exit 1
        fi
done

for SOFTWARE in ${software_stage[@]}; do
        install_package $SOFTWARE 2>&1 | tee -a "$LOG"
        if [ $? -ne 0 ]; then
            echo -e "\e[1A\e[K${ERROR} - $SOFTWARE install had failed, please check the install.log"
            exit 1
        fi
done

for MYPKG in ${other_toys[@]}; do
    install_package $MYPKG 2>&1 | tee -a "$LOG"
        if [ $? -ne 0 ]; then
            echo -e "\e[1A\e[K${ERROR} - $MYPKG install had failed, please check the install.log"
            exit 1
        fi
done


### Additional packages (File Manager)
read -n1 -rep "${CAT} OPTIONAL - Would you like to install Thunar as file manager? (y/n)" inst3
echo
if [[ $inst3 =~ ^[Yy]$ ]]; then
    sleep 1
    for FM in ${file_manager[@]}; do
    install_package $FM 2>&1 | tee -a "$LOG"
        if [ $? -ne 0 ]; then
            echo -e "\e[1A\e[K${ERROR} - $FM install had failed, please check the install.log"
            exit 1
        fi
    done
else
    printf "${NOTE} Thunar will not be installed.\n"
fi

clear

### Bluetooth
read -n1 -rep "${CAT} OPTIONAL - Would you like to install Bluetooth packages? (y/n)" inst4
if [[ $inst4 =~ ^[Yy]$ ]]; then
    printf "${NOTE} Installing Bluetooth Packages...\n"
    for BLUE in blueman bluez bluez-utils; do
        install_package "$BLUE" 2>&1 | tee -a "$LOG"
        if [ $? -ne 0 ]; then
        echo -e "\e[1A\e[K${ERROR} - $BLUE install had failed, please check the install.log"
        exit 1
        fi
    done
else
    printf "${NOTE} No bluetooth packages installed..\n"
fi

clear

### Fonts installation
printf "\n%s - Installing fonts  \n" "${NOTE}"
FONTSDIR=~/.fonts
sudo pacman -S --noconfirm ttf-font-awesome
if [ -d "$FONTSDIR" ]; then
    echo -e "$OK - $FONTSDIR found"
else
    echo -e "$NOTE - $FONTSDIR NOT found, creating..."
    mkdir $FONTSDIR
fi
sleep 2
cp -r assets/*ttf $FONTSDIR
#tar -zxvf assets/fonts.tar.gz -C $FONTSDIR
fc-cache -fv
sleep 3 

clear

### Done
printf "\n${OK} Installation Completed.\n"
printf "\n"
printf "\n"

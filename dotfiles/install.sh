echo "Installing rchrdwllm's dotfiles..."
echo "Copying .config and Wallpapers to /home directory..."

cp -r .config $HOME
export PATH="${PATH}:${HOME}/.local/bin/"
#cp -r Wallpapers $HOME

echo "Successfully copied files!"
echo "Copying SDDM theme to /usr/share/sddm/themes..."
echo "Your password is needed for this one"

### Various substitutions
sed -i "s/irako/$USER"/ dotfiles/usr/share/sddm/themes/sugar-candy/theme.conf
sudo cp -r usr/share/sddm/themes/sugar-candy/* /usr/share/sddm/themes/sugar-candy/
sudo cp -r lib/sddm/sddm.conf.d/default.conf /lib/sddm/sddm.conf.d/
sudo cp -r Anime /usr/share/sddm/themes
sudo cp irako.png /usr/share/sddm/faces/$USER.face.icon
sudo sed -i "s/^Current=.*/Current=Anime/g" /lib/sddm/sddm.conf.d/default.conf
sed -i "s/irako/$USER/" dotfiles/.config/BetterDiscord/themes/pywal-discord-default.theme.css
sed -i "s/irako/$USER/" dotfiles/.config/firefox/userChrome.css
sed -i "s/irako/$USER/" dotfiles/.config/firefox/home/style.css
sed -i "s/irako/$USER/" dotfiles/.config/hypr/hyprland.conf
sleep 2

echo "Successfully copied SDDM theme!"

echo "Enabling services SDDM and bluetooth services..."

systemctl enable sddm.service
systemctl enable bluetooth.service

echo "Successfully enabled services!"

echo "Setting a first colors palette to avoid errors after reboot..."
DIR=$HOME/.config/hypr/wallpapers
PICS=($(ls ${DIR}))

RANDOMPICS=${PICS[ $RANDOM % ${#PICS[@]} ]}
echo $DIR/$RANDOMPICS > $HOME/.cache/mywall
# I'm using the 16 colors version of pywal, if you use the standard one please use the row below instead
wal -i ${DIR}/${RANDOMPICS} --cols16
#wal -i ${DIR}/${RANDOMPICS} --cols16

echo "Successfully set a new wallpaper and generated colors from it."

echo "Do NOT reboot your system yet !"
echo "Please proceed with the tasks on the README.md"
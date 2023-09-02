#!/bin/bash

sudo apt update -y
sudo apt upgrade -y
# Set console font

sudo apt install fonts-terminus -y
setfont /usr/share/consolefonts/CyrAsia-TerminusBold22x11.psf.gz

# Install nala
sudo apt install nala -y
packages=(
  # terminal
  fish kitty tmux

  # editor
  vim 

  # launchers
  rofi suckless-tools

  # file managers
  ranger nemo exa 

  # theming
  feh lxappearance qt5ct qt6ct plymouth-themes
   
  # notifications
  dunst libnotify-bin

  # sound
  pipewire pavucontrol libspa-0.2-bluetooth alsa-utils

  # utils
  x11-utils psmisc unzip curl  zram-tools 
  btop bat tldr python3-pip ripgrep fd-find 
  virtualenv flatpak mpv wine
 	x11-xserver-utils

  # picom
  picom

  # buld neovim
  ninja-build gettext cmake

  # config neovim 
  ruby npm

  # browsers
  firefox-esr

  # misc
  qbittorrent keepassxc blueman 
  gnome-calculator gnome-calendar gnome-disk-utility
  zathura zathura-pdf-poppler
  gpick flameshot krita

  # polkit
  policykit-1-gnome

  # dwm build requirements
  make build-essential libx11-dev libxft-dev libimlib2-dev libxinerama-dev xinit libx11-xcb-dev libxcb-res0-dev
)

sudo nala install ${packages[@]}  -y

# display manager
packages=(
  sddm 
  qml-module-qtquick-layouts 
  qml-module-qtgraphicaleffects 
  qml-module-qtquick-controls2 
  libqt5svg5
)

sudo nala install ${packages[@]} --no-install-recommends -y


# sddm theming
if [ ! -d /usr/share/sddm/themes/ ] ; then
  sudo mkdir /usr/share/sddm/themes/
fi

git clone https://github.com/catppuccin/sddm.git
sudo mv ./sddm/src/catppuccin-mocha /usr/share/sddm/themes/
rm sddm -rdf

cat > ./tmp << EOF
[Theme]
Current=catppuccin-mocha
EOF

sudo mv ./tmp /etc/sddm.conf

# Setup swap
sudo sed -i 's/#ALGO.*/ALGO=zstd/g' /etc/default/zramswap
sudo sed -i 's/#PERCENT.*/PERCENT=25/g' /etc/default/zramswap

# Set starting directory
BASEDIR=$(dirname "$0")

# install dwm and dwmblocks
sudo make -C $BASEDIR/dwm/ clean install 
sudo make -C $BASEDIR/dwmblocks/ clean install 

sudo make -C $BASEDIR/dwm/ clean 
sudo make -C $BASEDIR/dwmblocks/ clean

# Add dwm scripts to path
cat >> ~/.profile << EOF

# add dwm scripts to path
if [ -d "$(realpath $BASEDIR/scripts)" ] ; then
  PATH="$(realpath $BASEDIR/scripts):tempvar"
fi
EOF

sed -i 's/tempvar/$PATH/g' ~/.profile # tempvar to avod path unpacking


# Create desktop entry for DWM
if [[ ! -d /usr/share/xsessions ]]; then
    sudo mkdir /usr/share/xsessions
fi


# Create dwm-session launcher
cat > ./tmp << EOF
#!/bin/bash

dwm-autostart

while type dwm >/dev/null; do 
  dwm && continue || break; 
done
EOF

sudo cp ./tmp /usr/local/bin/dwm-session
sudo chmod +x /usr/local/bin/dwm-session
rm ./tmp

cat > ./tmp << EOF
[Desktop Entry]
Encoding=UTF-8
Name=dwm
Comment=Dynamic Window Manager
Exec=dwm-session
Type=XSession
EOF

sudo cp ./tmp /usr/share/xsessions/dwm.desktop
rm ./tmp


# Build Neovim
if ! command -v nvim ; then
  git clone https://github.com/neovim/neovim
  git -C $BASEDIR/neovim checkout stable
  make -C $BASEDIR/neovim CMAKE_BUILD_TYPE=RelWithDebInfo 
  sudo make -C $BASEDIR/neovim install 
  rm neovim -rdf

  if [ ! -d $HOME/.local/share/applications ] ; then
      mkdir -p $HOME/.local/share/applications 
  fi

  cp -rf /usr/local/share/applications/nvim.desktop $HOME/.local/share/applications/
  sed -i 's/Exec=nvim %F/Exec=kitty -e nvim %F/g' $HOME/.local/share/applications/nvim.desktop
  sed -i 's/Terminal=true/Terminal=false/g' $HOME/.local/share/applications/nvim.desktop  

  sudo nala install python3-pynvim -y --no-install-recommends
fi


# Set fish as default shell
if [ ! -d $HOME/.ssh ] ; then
    mkdir -p $HOME/.ssh
fi
sudo chsh $USER -s $(which fish)


# Install Starship
if ! command -v starship ; then
curl -sS https://starship.rs/install.sh | sudo sh -s -- --yes
fi

# dotfiles
if [ -d $HOME/.dotfiles ] ; then
  rm -rdf $HOME/.dotfiles
fi

git clone --bare https://github.com/gravegrow/dotfiles $HOME/.dotfiles

function dotfiles {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}

mkdir -p .config-backup

dotfiles checkout
if [ $? = 0 ]; then
  echo "Checked out config.";
else
  echo "Backing up pre-existing dot files.";
  dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
dotfiles checkout  
dotfiles config status.showUntrackedFiles no
rm -rdf .config-backup

# poetry
curl -sSL https://install.python-poetry.org | python3 -

# nemo 
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
gsettings set org.cinnamon.desktop.default-applications.terminal exec kitty
gsettings set org.gnome.desktop.default-applications.terminal exec kitty
gsettings set org.nemo.desktop show-desktop-icons false

cat > ~/.config/user-dirs.dirs << EOF
XDG_DESKTOP_DIR="$HOME/Desktop"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_PICTURES_DIR="$HOME/Pictures"
XDG_PUBLICSHARE_DIR="$HOME/.publicshare"
XDG_DOCUMENTS_DIR="$HOME/.misc"
XDG_MUSIC_DIR="$HOME/.misc"
XDG_TEMPLATES_DIR="$HOME/.templates"
XDG_VIDEOS_DIR="$HOME/.misc"
EOF

for dir in "Desktop" "Pictures" "Downloads" ".publicshare" ".misc" ".templates"
do
  mkdir $HOME/$dir 
done

xdg-user-dirs-update

# fonts
if [ ! -d $HOME/.local/share/fonts ] ; then
    mkdir -p $HOME/.local/share/fonts 
fi


if [ ! -d $HOME/.local/share/fonts/JetBrainsMono ]; then
  wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip"
  unzip -oq JetBrainsMono.zip -d $HOME/.local/share/fonts/JetBrainsMono
  rm JetBrainsMono.zip 
fi


THEMES_DIR=/usr/share/themes

if [ ! -d $THEMES_DIR ] ; then 
  mkdir $THEMES_DIR
fi

# gtk

THEME=Catppuccin-Mocha-Standard-Lavender-dark
CAT_THEME=$THEMES_DIR/$THEME
wget "https://github.com/catppuccin/gtk/releases/download/v0.6.1/$THEME.zip"
sudo unzip -oq "$THEME.zip" -d $THEMES_DIR
rm "$THEME.zip"

sudo ln -sf "$CAT_THEME/gtk-4.0/assets" "$HOME/.config/gtk-4.0/assets"
sudo ln -sf "$CAT_THEME/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
sudo ln -sf "$CAT_THEME/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"

for ver in "gtk-3.0" "gtk-4.0"
do
cat >> $CAT_THEME/$ver/gtk.css << EOF
/* remove window title from Client-Side Decorations */
.solid-csd headerbar .title {
    font-size: 0;
}

/* hide extra window decorations/double border */
window decoration {
    margin: 0;
    border: none;
    padding: 0;
}

.background {
  margin: 0;
  padding: 0;
  box-shadow: 0 0 0 0;
}

* {
  text-shadow: none;
}

/* Always use background color */
GtkWindow {
    background-color: @theme_bg_color;
}

/* Fix tooltip background override */
.tooltip {
    background-color: rgba(0, 0, 0, 0.8);
}

.tooltip * {
    background-color: transparent;
}
EOF
done 

# cursor
if [ ! -d /usr/share/icons ] ; then 
  mkdir /usr/share/icons -p
fi

wget "https://github.com/alvatip/Nordzy-cursors/releases/download/v0.6.0/Nordzy-cursors-white.tar.gz"
tar xzf Nordzy-cursors-white.tar.gz
sudo mv Nordzy-cursors-white /usr/share/icons/
rm Nordzy-cursors-white* -rdf

if [ ! -f $HOME/.Xresources ] ; then 
  touch $HOME/.Xresources
fi

echo "Xcursor.theme: Nordzy-cursors-white" | tee --append ~/.Xresources

# icons
git clone https://github.com/bikass/kora.git
sudo mv ./kora/kora* /usr/share/icons/
rm kora -rdf


cat > ./tmp << EOF
[Settings]
gtk-theme-name=Catppuccin-Mocha-Standard-Lavender-dark
gtk-icon-theme-name=kora
gtk-font-name=JetBrainsMono Nerd Font Light 9
gtk-cursor-theme-name=Nordzy-cursors-white
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-xft-rgba=none
EOF

sudo mv ./tmp /etc/gtk-3.0/settings.ini


# plymouth and grub
git clone https://github.com/vikashraghavan/dotLock.git
sudo cp -r ./dotLock/dotLock /usr/share/plymouth/themes/
sudo plymouth-set-default-theme dotLock -R
rm dotLock/ -rdf

sudo sed -i 's/#GRUB_GFXMODE=.*/GRUB_GFXMODE=1920x1080x32/g' /etc/default/grub
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/g' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/g' /etc/default/grub

sudo update-grub2

# flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# # nix
# curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes
#
# if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
#   . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
# fi

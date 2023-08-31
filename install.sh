#!/bin/bash

# Check if running as root
# if [ "$EUID" -ne 0 ]
#   then echo "Please run as root"
#   exit
# fi

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
  # vim 

  # launchers
  rofi suckless-tools

  # file managers
  ranger nemo exa 

  # theming
  feh lxappearance qt6ct
   
  # notifications
  dunst libnotify-bin

  # sound
  pipewire pavucontrol libspa-0.2-bluetooth alsa-utils

  # utils
  x11-utils psmisc unzip curl  zram-tools 
  btop bat tldr python3-pip ripgrep fd-find 
  virtualenv

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
  gnome-calculator gnome-calendar
  zathura zathura-pdf-poppler

  # display manager
  lightdm

  # dwm build requirements
  make build-essential libx11-dev libxft-dev libimlib2-dev libxinerama-dev xinit libx11-xcb-dev libxcb-res0-dev
)

sudo nala install ${packages[@]} -y

# NIX
# curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes
#
# if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
#   . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
# fi


# Setup lightdm session-wrapper so it can source .profile
wget https://raw.githubusercontent.com/canonical/lightdm/master/debian/lightdm-session
chmod +x lightdm-session
sudo mv lightdm-session /usr/sbin/lightdm-session

sudo sed -i 's/#greeter-hide-users=false/greeter-hide-users=false/g' /etc/lightdm/lightdm.conf
sudo sed -i 's/#session-wrapper=lightdm-session/session-wrapper=lightdm-session/g' /etc/lightdm/lightdm.conf

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
if [ ! -f /usr/bin/nvim ] ; then
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
  sudo nala install python3-neovim -y
fi


# Set fish as default shell
sudo chsh $USER -s $(which fish)


# Install Starship
if [ ! -f /usr/local/bin/starship ] ; then
  curl -s https://api.github.com/repos/starship/starship/releases/latest \
    | grep browser_download_url \
    | grep x86_64-unknown-linux-gnu \
    | cut -d '"' -f 4 \
    | wget -qi -

  tar -zxf starship-*.tar.gz
  sudo mv starship /usr/local/bin/
  rm starship*
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
gsettings set org.gnome.desktop.default-applications.terminal exec kitty
gsettings set org.nemo.desktop show-desktop-icons false


# fonts
if [ ! -d $HOME/.local/share/fonts ] ; then
    mkdir -p $HOME/.local/share/fonts 
fi


if [ ! -d $HOME/.local/share/fonts/JetBrainsMono ]; then
  wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip"
  unzip -oq JetBrainsMono.zip -d $HOME/.local/share/fonts/JetBrainsMono
  rm JetBrainsMono.zip 
fi

if [ ! -d $HOME/.themes ] ; then 
  mkdir $HOME/.themes
fi

# gtk
mkdir -p "$HOME/.config/gtk-3.0"
mkdir -p "$HOME/.config/gtk-4.0"

THEME=Catppuccin-Mocha-Standard-Lavender-dark
THEME_DIR=$HOME/.themes/$THEME

wget "https://github.com/catppuccin/gtk/releases/download/v0.6.1/$THEME.zip"
unzip -oq "$THEME.zip" -d $HOME/.themes/
rm "$THEME.zip"

ln -sf "$THEME_DIR/gtk-4.0/assets" "$HOME/.config/gtk-4.0/assets"
ln -sf "$THEME_DIR/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
ln -sf "$THEME_DIR/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"

for ver in "gtk-3.0" "gtk-4.0"
do
cat >> $THEME_DIR/$ver/gtk.css << EOF
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

* {
  text-shadow: none;
}
EOF
done 

# cursor
if [ ! -d $HOME/.icons ] ; then 
  mkdir $HOME/.icons
fi

wget "https://github.com/alvatip/Nordzy-cursors/releases/download/v0.6.0/Nordzy-cursors-white.tar.gz"
tar xzf Nordzy-cursors-white.tar.gz
rm Nordzy-cursors-white.tar.gz
mv Nordzy-cursors-white $HOME/.icons

# icons
git clone https://github.com/bikass/kora.git
mv ./kora/kora* $HOME/.icons
rm kora -rdf

cat > $HOME/.config/gtk-3.0/settings.ini << EOF
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



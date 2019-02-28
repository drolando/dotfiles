#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERROR="$RED[ERROR]$NC"
INFO="$BLUE[INFO]$NC"
OK="$GREEN[SUCCESS]$NC"

CURR_DIR=$(pwd)

function fail_on_error {
    if [[ $? -ne 0 ]]
    then
        echo -e "$ERROR $1"
        exit 1
    fi
}

# Clone a repository and exit on failure
function clone {
    git clone "$2" "$3" > /dev/null
    fail_on_error "Failed to download $1"
}

# Update a repository and exit on failure
function update {
    cd "$2" || exit
    git fetch origin > /dev/null
    git pull > /dev/null
    fail_on_error "Failed to update $1"
    cd "$CURR_DIR" || exit > /dev/null
}

# Cleans a repository and exit on failure
function clean {
    cd "$2" || exit
    git clean -fd > /dev/null
    fail_on_error "Failed to clean $1"
    git reset > /dev/null
    fail_on_error "Failed to clean $1"
    git checkout . > /dev/null
    fail_on_error "Failed to clean $1"
    cd "$CURR_DIR" || exit > /dev/null
}

# Create a symbolic link and exit on failure
function link {
    if [[ ! -f $2 && ! -L $2 ]]
    then
        echo -e "$INFO Linking $2"
        ln -s "$1" "$2"
        fail_on_error "Failed to create symlink $2"
    else
        # If the file esists but it's not a symbolic link, backup it and
        # create the symbolic link
        if [[ ! -L $2 ]]
        then
            echo -e "$INFO Backing up old file as $2.old"
            mv "$2" "$2.old"
            fail_on_error "Failed to backup $2"

            echo -e "$INFO Linking $2"
            ln -s "$1" "$2"
            fail_on_error "Failed to create symlink $2"
        else
            echo -e "$INFO Skipping $HOME/.$2"
        fi
    fi
}


# ===============================================================================
# ================================  UPDATE REPO  ================================
# ===============================================================================
echo -e "$INFO Updating repo"
ussh &> /dev/null
update .dotfiles .
echo -e "$OK Repository successfully updated"


# ===============================================================================
# =============================  VIM CONFIGURATION  =============================
# ===============================================================================
mkdir -p "$HOME/.vim"
mkdir -p "$HOME/.vim/plugged"

# Creates the autoload directory if it doesn't exist
if [ ! -d "$HOME/.vim/autoload" ]
then
    echo -e "$INFO Downloading vim-plug"
    clone "vim-plug" https://github.com/junegunn/vim-plug.git "$HOME/.vim/autoload"
else
    echo -e "$INFO Updating vim-plug"
    update "vim-plug" "$HOME/.vim/autoload"
fi

if [ "$1" == "--nvim" ]; then
  if [ ! -d "$HOME/.local/share/nvim/site/autoload" ]; then
      echo -e "$INFO creating neovim autoload directory"
      mkdir -p "$HOME/.local/share/nvim/site"
      link "$HOME/.vim/autoload" "$HOME/.local/share/nvim/site/autoload"
  fi
fi

# Install solarized
# ------------------
if [ ! -d "$CURR_DIR/solarized" ]
then
    echo -e "$INFO Downloading the patched fonts"
    clone solarized https://github.com/altercation/solarized.git "$CURR_DIR/solarized"
else
    echo -e "$INFO Updating the patched fonts"
    update solarized "$CURR_DIR/solarized"
fi

mkdir -p "$HOME/.vim/colors/"
cp "$CURR_DIR/solarized/vim-colors-solarized/colors/solarized.vim" "$HOME/.vim/colors/"
mkdir -p "$HOME/.config/nvim/colors/"
cp "$CURR_DIR/solarized/vim-colors-solarized/colors/solarized.vim" "$HOME/.config/nvim/colors/"
fail_on_error "Failed to install solarized schema"
echo -e "$OK Solarized schema installed"

# Install plugins
# ---------------
link "$CURR_DIR/vimrc" "$HOME/.vimrc"
link "$CURR_DIR/vimrc.plugins" "$HOME/.vimrc.plugins"

vim +PlugUpgrade +qall
vim +PlugClean! +qall
vim +PlugInstall +qall
vim +PlugUpdate +qall

if [ "$1" == "--nvim" ]; then
  if [[ ! -e "$HOME/.config/nvim/init.vim" ]]; then
      mkdir -p "$HOME/.config/nvim/"
      link "$CURR_DIR/vimrc" "$HOME/.config/nvim/init.vim"
  fi
  nvim +PlugUpgrade +qall
  nvim +PlugClean! +qall
  nvim +PlugInstall +qall
  nvim +PlugUpdate +qall
fi

echo -e "$OK Vim plugins successfully updated"

# Download patched fonts
# ----------------------
if [ ! -d "$CURR_DIR/fonts" ]
then
    echo -e "$INFO Downloading the patched fonts"
    clone fonts https://github.com/powerline/fonts.git "$CURR_DIR/fonts"
else
    echo -e "$INFO Updating the patched fonts"
    update fonts "$CURR_DIR/fonts"
fi

# Install patched fonts
cd "$CURR_DIR/fonts" || exit
./install.sh
fail_on_error "Failed to install patched fonts"
echo -e "$OK Patched fonts updated"
cd "$CURR_DIR" || exit


# ===============================================================================
# ===================================  ZSH  =====================================
# ===============================================================================
if [[ ! -d $HOME/.oh-my-zsh ]]
then
    echo -e "$INFO Downloading oh-my-zsh"
    clone on-my-zsh git://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh"
else
    echo -e "$INFO Updating oh-my-zsh"
    clean oh-my-zsh "$HOME/.oh-my-zsh"
    update oh-my-zsh "$HOME/.oh-my-zsh"
fi

if [[ ! -f $HOME/.oh-my-zsh/themes/drolando.zsh-theme ]]
then
    link "$CURR_DIR/zsh/drolando.zsh-theme" "$HOME/.oh-my-zsh/themes/drolando.zsh-theme"
fi

if [[ ! -d $CURR_DIR/zsh/zsh-syntax-highlighting ]]
then
    echo -e "$INFO Downloading zsh-syntax-highlighting"
    clone "zsh-syntax-highlighting" https://github.com/zsh-users/zsh-syntax-highlighting.git "$CURR_DIR/zsh/zsh-syntax-highlighting"
else
    echo -e "$INFO Updating zsh-syntax-highlighting"
    update "zsh-syntax-highlighting" "$CURR_DIR/zsh/zsh-syntax-highlighting"
fi

link "$CURR_DIR/zsh/zshrc" "$HOME/.zshrc"

# ===============================================================================
# =================================  SYMLINKS  ==================================
# ===============================================================================
for dot in boto gitconfig tmux.conf
do
  link "$CURR_DIR/$dot" "$HOME/.$dot"
done
echo -e "$OK Dotfiles correctly linked"

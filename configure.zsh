#!/usr/bin/env zsh

source $(pwd)/common.zsh

# ===============================================================================
# ================================  UPDATE REPO  ================================
# ===============================================================================
update .dotfiles .

# ===============================================================================
# =============================  VIM CONFIGURATION  =============================
# ===============================================================================
update_or_clone "vim-plug" https://github.com/junegunn/vim-plug.git "$HOME/.vim/autoload"

which nvim &> /dev/null
if [[ $? -eq 0 ]]
then
    mkdir -p "$HOME/.local/share/nvim/site"
    link "$HOME/.vim/autoload" "$HOME/.local/share/nvim/site/autoload"
fi

# Install solarized
# ------------------
update_or_clone solarized https://github.com/altercation/solarized.git "$CURR_DIR/solarized"

VIM_COLORS="$HOME/.vim/colors/"
NVIM_COLORS="$HOME/.config/nvim/colors/"

mkdir -p "$HOME/.vim/colors/"
cp "$CURR_DIR/solarized/vim-colors-solarized/colors/solarized.vim" $VIM_COLORS
mkdir -p "$HOME/.config/nvim/colors/"
cp "$CURR_DIR/solarized/vim-colors-solarized/colors/solarized.vim" $NVIM_COLORS
if [[ -f $VIM_COLORS/solarized.vim && -f $NVIM_COLORS/solarized.vim ]]
then
    green Successfully installed solarized colors
else
    red Failed to install solarized colors
    exit 1
fi

# Install plugins
# ---------------
link "$CURR_DIR/coc-settings.json" "$HOME/.vim/coc-settings.json"

for VIM in vim nvim
do
    $VIM +PlugUpgrade +qall
    $VIM +PlugClean! +qall
    $VIM +PlugInstall +qall
    $VIM +PlugUpdate +qall
    $VIM +"CocInstall coc-python" +qall
    $VIM +CocUpdate +qall
done

green Vim plugins updated

# Download patched fonts
# ----------------------
update_or_clone fonts https://github.com/powerline/fonts.git "$CURR_DIR/fonts"

# Install patched fonts
cd "$CURR_DIR/fonts" || exit
./install.sh > /dev/null
fail_on_error "Failed to install patched fonts"
green Patched fonts updated
cd "$CURR_DIR" || exit


# ===============================================================================
# ===================================  ZSH  =====================================
# ===============================================================================
yellow Updating oh-my-zsh
/usr/bin/env zsh -c "source ~/.zshrc && omz update" > /dev/null

update "zsh-syntax-highlighting" "$CURR_DIR/zsh/zsh-syntax-highlighting"

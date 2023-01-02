#!/bin/bash

# Symlink Kitty terminal config
if [ ! -d $HOME/.config/kitty ]; then
  mkdir $HOME/.config/kitty
else
  echo "kitty config dir existed"
fi
ln -s ~/.dotfiles/tool/kitty/kitty.conf ~/.config/kitty/kitty.conf



echo "config LS_COLORS"
mkdir /tmp/LS_COLORS && curl -L https://api.github.com/repos/vpeopleonatank/LS_COLORS/tarball/master | tar xzf - --directory=/tmp/LS_COLORS --strip=1
( cd /tmp/LS_COLORS && sh install.sh )

echo "turn off tmux auto restore"
touch ~/tmux_no_auto_restore

# Symlink config
echo "Symlink init.vim"
sudo ln -s $HOME/.dotfiles/tool/vim/init.vim $HOME/.config/nvim/init.vim

sudo ln -s $HOME/.dotfiles/tool/vim/coc-settings-nvim.json $HOME/.config/nvim/coc-settings.json
echo "Symlink coc-settings-nvim.json done"
sudo ln -s $HOME/.dotfiles/tool/vim/lua $HOME/.config/nvim/lua
sudo ln -s $HOME/.dotfiles/tool/snippets $HOME/.config/snippets
echo "Install neovim Plugins"
nvim --headless +PlugInstall +q

# config tmux
if [ ! -d $HOME/.tmux/plugins/tpm ]; then
    echo "install zsh-z"

  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
else
    echo "tpm is installed"
fi
echo 'source ~/.dotfiles/tool/tmux/config.tmux' >$HOME/.tmux.conf
echo "Symlink Tmux configuration successfully ^~^"

mkdir -p $HOME/.config/jesseduffield/lazygit
sudo ln -s $HOME/.dotfiles/tool/lazygit/config.yml $HOME/.config/jesseduffield/lazygit/config.yml
mkdir -p $HOME/.config/jesseduffield/lazygit
sudo ln -s $HOME/.dotfiles/tool/lazygit/config.yml $HOME/.config/jesseduffield/lazygit/config.yml

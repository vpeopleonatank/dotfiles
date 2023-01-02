#!/bin/bash

# Symlink Kitty terminal config
if [ ! -d $HOME/.config/kitty ]; then
  mkdir $HOME/.config/kitty
else
  echo "kitty config dir existed"
fi
if [ -f $HOME/.config/kitty/kitty.conf ]
then
  ln -s ~/.dotfiles/tool/kitty/kitty.conf ~/.config/kitty/kitty.conf
fi


echo "turn off tmux auto restore"
touch ~/tmux_no_auto_restore

# Symlink config
echo "Symlink nvim config"
if [ ! -d $HOME/.config/nvim ]; then
  mkdir $HOME/.config/nvim
fi
sudo ln -s $HOME/.dotfiles/tool/vim/init.vim $HOME/.config/nvim/init.vim
sudo ln -s $HOME/.dotfiles/tool/vim/coc-settings-nvim.json $HOME/.config/nvim/coc-settings.json
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
if [ ! -d $HOME/.config/jesseduffield/lazygit ]; then
then
  mkdir -p $HOME/.config/jesseduffield/lazygit
fi
sudo ln -s $HOME/.dotfiles/tool/lazygit/config.yml $HOME/.config/jesseduffield/lazygit/config.yml

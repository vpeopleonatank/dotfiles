set +e
set -u

# config vim
echo 'source $HOME/.dotfiles/tool/vim/.vimrc' >$HOME/.vimrc

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "PlugInstall for vim"
vim +PlugInstall +qall > /dev/null
echo "Installed Vim configuration successfully ^~^"

echo "Symlink vim and neovim 's coc-settings.json"
# sudo ln -s $HOME/.dotfiles/tool/vim/coc-settings-nvim.json $HOME/.config/nvim/coc-settings.json
sudo ln -s $HOME/.dotfiles/tool/vim/coc-settings-vim.json $HOME/.vim/coc-settings.json
echo "Symlink done"

echo "Symlink efm-langserver config"
sudo ln -s $HOME/.dotfiles/tool/config/config.yaml $HOME/.config/efm-langserver/config.yaml
echo "Symlink done"


sudo ln -s $HOME/.dotfiles/tool/vim/init.vim $HOME/.config/nvim/init.vim
echo "Symlink init.vim done"

sudo ln -s $HOME/.dotfiles/tool/vim/coc-settings-nvim.json $HOME/.config/nvim/coc-settings.json
echo "Symlink coc-settings-nvim.json done"

sudo ln -s $HOME/.dotfiles/tool/vim/lua $HOME/.config/nvim/lua

sudo ln -s $HOME/.dotfiles/tool/snippets $HOME/.config/snippets


mkdir -p $HOME/.config/jesseduffield/lazygit
sudo ln -s $HOME/.dotfiles/tool/lazygit/config.yml $HOME/.config/jesseduffield/lazygit/config.yml

# config tmux
echo 'source ~/.dotfiles/tool/tmux/config.tmux' >$HOME/.tmux.conf
echo "Installed Tmux configuration successfully ^~^"

# install fonts
if [ ! -d $HOME/.dotfiles/fonts ]; then
    echo "install fonts"
    git clone https://github.com/powerline/fonts.git $HOME/.dotfiles/fonts
    sh $HOME/.dotfiles/fonts/install.sh
else
    echo "fonts is installed"
fi

# nodejs
if [ ! -d $HOME/.dotfiles/nodejs/bin ]; then
    echo "install nodejs"
    mkdir $HOME/.dotfiles/nodejs
    curl -sL install-node.now.sh/lts | bash -s -- --prefix=$HOME/.dotfiles/nodejs --version=lts --verbose
else
    echo "node is installed"
fi
echo 'source $HOME/.dotfiles/tool/zsh/config.zsh' >$HOME/.zshrc

# install powerlevel10k for zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
exec $(which zsh)
source $HOME/.zshrc
p10k configure
sed -i '/CONTENT,VISUAL_IDENTIFIER/d' ~/.p10k.zsh

# Install fonts and rebuild font cache
if [ ! -d $HOME/.local/share/fonts/NerdFonts ]; then
		mkdir -p $HOME/.local/share/fonts/NerdFonts
else
	echo "~/.local/share/fonts/NerdFonts dir existed"
fi

unzip "./fonts/*.zip" -d ${HOME}/.local/share/fonts/NerdFonts/
# cp ./fonts/* $HOME/.local/share/fonts/NerdFonts/
sudo fc-cache -f -v
echo "Install and recache fonts"

# alacritty
if [ ! -d $HOME/.config/alacritty ]; then
  mkdir $HOME/.config/alacritty
else
  echo "alacritty config dir existed"
fi
ln -s $HOME/.dotfiles/tool/alacritty/alacritty.yml $HOME/.config/alacritty/alacritty.yml

# Symlink Kitty terminal config
if [ ! -d $HOME/.config/kitty ]; then
  mkdir $HOME/.config/kitty
else
  echo "kitty config dir existed"
fi
ln -s ~/.dotfiles/tool/kitty/kitty.conf ~/.config/kitty/kitty.conf



if [ ! -d $HOME/.vim/UltiSnips ]; then
  mkdir $HOME/.vim/UltiSnips
else
  echo "$HOME/.vim/UltiSnips dir existed"
fi
cp $HOME/.dotfiles/tool/templates/tex.snippets $HOME/.vim/UltiSnips/


if [ ! -d $HOME/.tmux/plugins/tpm ]; then
    echo "install zsh-z"

  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
else
    echo "tpm is installed"
fi

echo "config LS_COLORS"
mkdir /tmp/LS_COLORS && curl -L https://api.github.com/repos/vpeopleonatank/LS_COLORS/tarball/master | tar xzf - --directory=/tmp/LS_COLORS --strip=1
( cd /tmp/LS_COLORS && sh install.sh )

echo "turn off tmux auto restore"
touch ~/tmux_no_auto_restore

function install_fonts() {
    fonts_dir="${HOME}/.local/share/fonts"
    if [ ! -d "${fonts_dir}" ]; then
      echo "mkdir -p $fonts_dir"
      mkdir -p "${fonts_dir}"
    else
      echo "Found fonts dir $fonts_dir"
    fi

    for type in Bold Medium Italic 'Bold Italic'; do
      file_path="${HOME}/.local/share/fonts/JetBrainsMono-${type}.ttf"
      file_url="https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/JetBrainsMono/Ligatures/${type}/complete/JetBrains%20Mono%20${type}%20Nerd%20Font%20Complete%20Mono.ttf?raw=true"
      if [ "$type" == "Bold Italic" ]; then
        file_url="https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/JetBrainsMono/Ligatures/BoldItalic/complete/JetBrains%20Mono%20${type}%20Nerd%20Font%20Complete%20Mono.ttf?raw=true"
      fi

    if [ ! -e "${file_path}" ]; then
          echo "wget -O $file_path $file_url"
          wget -O "${file_path}" "${file_url}"
      else
    echo "Found existing file $file_path"
      fi;
    done
    echo "fc-cache -f"
    sudo fc-cache -f
}

install_fonts

# If use kitty terminal, add following line to $HOME/.config/fontconfig/fonts.conf
# Source: https://github.com/ryanoasis/nerd-fonts/issues/268#issuecomment-693481697

# <match target="scan">
#       <test name="family">
#           <string>JetBrainsMono Nerd Font</string>
#       </test>
#       <edit name="spacing">
#           <int>100</int>
#       </edit>
#   </match>

# TODO 've not found way to append multiple line to file in bash function
# change_gnome_tittle_bar() {
#     cat <<EOT >> ~/.config/gtk-3.0/gtk.css
#         .titlebar {
#             background: #6272A4;
#             color:white;
#         }
#
#         .titlebar:backdrop  {
#             background: #777777;
#             color:white;
#         }
#         EOT
#
#     setsid gnome-shell --replace
# }
#
# change_gnome_tittle_bar

# Install gdb-dashboard
# echo "Install gdb-dashboard"
# pip install pygments
# wget -P ~ https://git.io/.gdbinit
# mkdir $HOME/.gdbinit.d/
# touch $HOME/.gdbinit.d/init
# echo "dashboard -layout  expressions history stack breakpoints source variables" > $HOME/.gdbinit.d/init

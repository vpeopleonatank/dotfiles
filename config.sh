set +e
set -u

# config vim
echo 'source $HOME/.dotfiles/tool/vim/.vimrc' >$HOME/.vimrc
# if [ ! -d $HOME/.config/nvim ]; then
#     echo "Neovim setup"
#     mkdir $HOME/.config/nvim
# fi
#echo -e "set runtimepath^=~/.vim runtimepath+=~/.vim/after\nlet &packpath = &runtimepath\nsource $HOME/.dotfiles/tool/vim/config.vim" >$HOME/.config/nvim/init.vim

echo "PlugInstall for vim"
vim +PlugInstall +qall > /dev/null
echo "Installed Vim configuration successfully ^~^"



# config tmux
echo 'source ~/.dotfiles/tool/tmux/config.tmux' >$HOME/.tmux.conf
echo "Installed Tmux configuration successfully ^~^"

# install oh-my-zsh
if [ ! -d $HOME/.dotfiles/oh-my-zsh ]; then
    echo "install Oh-my-zsh"
    git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.dotfiles/oh-my-zsh
else
    echo "Oh-my-zsh is installed"
fi
# install powerlevel9k
if [ ! -d $HOME/.dotfiles/oh-my-zsh/themes/powerlevel9k ]; then
    echo "install powerlevel9k"
    git clone https://github.com/Powerlevel9k/powerlevel9k.git $HOME/.dotfiles/oh-my-zsh/themes/powerlevel9k
else
    echo "Powerlevel9k is installed"
fi
# install fonts
if [ ! -d $HOME/.dotfiles/fonts ]; then
    echo "install fonts"
    git clone https://github.com/powerline/fonts.git $HOME/.dotfiles/fonts
    sh $HOME/.dotfiles/fonts/install.sh
else
    echo "fonts is installed"
fi
# install syntax-highlighting
if [ ! -d $HOME/.dotfiles/oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
    echo "install syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.dotfiles/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
else
    echo "syntax_highlighting is installed"
fi
# autosuggestions
if [ ! -d $HOME/.dotfiles/oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    echo "install autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.dotfiles/oh-my-zsh/custom/plugins/zsh-autosuggestions
else
    echo "autosuggestions is installed"
fi


# install syntax-highlighting
if [ ! -d $HOME/.dotfiles/oh-my-zsh/custom/plugins/zshmarks ]; then
    echo "install zshmarks"
    git clone https://github.com/jocelynmallon/zshmarks $HOME/.dotfiles/oh-my-zsh/custom/plugins/zshmarks
else
    echo "zshmarks is installed"
fi

# k - ls alternative
if [ ! -d $HOME/.dotfiles/oh-my-zsh/custom/plugins/k ]; then
    echo "install k - ls alternative"
    git clone https://github.com/supercrabtree/k $HOME/.dotfiles/oh-my-zsh/custom/plugins/k
else
    echo "k is installed"
fi

# zsh-z

if [ ! -d $HOME/.dotfiles/oh-my-zsh/custom/plugins/zsh-z ]; then
    echo "install zsh-z"
    git clone  https://github.com/agkozak/zsh-z $HOME/.dotfiles/oh-my-zsh/custom/plugins/zsh-z
else
    echo "zsh-z is installed"
fi
# nodejs
if [ ! -d $HOME/.dotfiles/nodejs/bin ]; then
    echo "install nodejs"
    mkdir $HOME/.dotfiles/nodejs
    curl -sL install-node.now.sh/lts | bash -s -- --prefix=$HOME/.dotfiles/nodejs --version=lts --verbose
else
    echo "node is installed"
fi
# fzf
if [ ! -d $HOME/.dotfiles/oh-my-zsh/custom/plugins/fzf ]; then
    echo "install FZF"
    git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.dotfiles/oh-my-zsh/custom/plugins/fzf
    $HOME/.dotfiles/oh-my-zsh/custom/plugins/fzf/install
else
    echo "FZF is installed"
fi

export ZSH=$HOME/.dotfiles/oh-my-zsh
$HOME/.dotfiles/oh-my-zsh/tools/install.sh
echo 'Complete OH MY ZSH'
echo 'source $HOME/.dotfiles/tool/zsh/config.zsh' >$HOME/.zshrc

# alacritty
if [ ! -d $HOME/.config/alacritty ]; then
  mkdir $HOME/.config/alacritty
else
  echo "alacritty config dir existed"
fi
ln -s $HOME/.dotfiles/tool/alacritty/alacritty.yml $HOME/.config/alacritty/alacritty.yml


if [ ! -d $HOME/.scripts ]; then
  mkdir $HOME/.scripts
else
  echo "$HOME/.scripts dir existed"
fi
ln -s $HOME/.dotfiles/tool/scripts/generate_template.sh $HOME/.scripts/generate_template.sh


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

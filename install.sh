function install_nodejs() {
  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
  nvm install node # "node" is an alias for the latest version
  npm install --global yarn
}

function install_go() {
  if [ ! -d "$HOME/.local/bin/" ]
  then
    mkdir -p "$HOME/.local/bin/"
  fi
  curl -sL -o ~/.local/bin/gvm https://github.com/andrewkroh/gvm/releases/download/v0.5.0/gvm-linux-amd64
  sudo chmod +x ~/.local/bin/gvm
  eval "$(gvm 1.19.4)"
}

function install_rust() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  source $HOME/.cargo/env
}

function install_neovim() {
  wget https://github.com/neovim/neovim/releases/latest/download/nvim.appimage -O ~/.local/bin/nvim
  sudo chmod u+x ~/.local/bin/nvim
}

function install_exa() {
  cargo install exa
}

function install_ripgrep() {
  cargo install ripgrep
}

function install_kitty() {
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
  ln -s ~/.local/kitty.app/bin/kitty ~/.local/bin/
  cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications
}

function install_bat() {
  cargo install --locked bat
}

function install_fdfind() {
  cargo install fd-find
}

function install_zoxide() {
  cargo install zoxide --locked
}

sudo apt install tmux python3-dev python3-pip wget curl vim vim-gtk3 xclip -y

# install vim-plug for vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# install vim-plug for neovim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

pip3 install neovim pygments
sudo snap install universal-ctags
install_nodejs
# Install pyenv
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
install_rust
install_go
# Install lazygit and lazydocker
go install github.com/jesseduffield/lazygit@latest
go install github.com/jesseduffield/lazydocker@latest

mkdir -p ~/.local/bin/
install_ripgrep
install_bat
install_exa
install_fdfind
install_zoxide
install_neovim
install_kitty

echo "Install gdb-dashboard"
wget -P ~ https://git.io/.gdbinit

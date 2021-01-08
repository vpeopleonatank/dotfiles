function install_exa() {
  local v="0.9.0"
  ! command -v exa &>/dev/null || [[ "$(exa --version)" != *" v$v" ]] || return 0
  local tmp
  tmp="$(mktemp -d)"
  pushd -- "$tmp"
  curl -fsSLO "https://github.com/ogham/exa/releases/download/v${v}/exa-linux-x86_64-${v}.zip"
  unzip exa-linux-x86_64-${v}.zip
  sudo install -DT ./exa-linux-x86_64 /usr/local/bin/exa
  popd
  rm -rf -- "$tmp"
}

function install_ripgrep() {
  local v="12.1.1"
  ! command -v rg &>/dev/null || [[ "$(rg --version)" != *" $v "* ]] || return 0
  local deb
  deb="$(mktemp)"
  curl -fsSL "https://github.com/BurntSushi/ripgrep/releases/download/${v}/ripgrep_${v}_amd64.deb" >"$deb"
  sudo dpkg -i "$deb"
  rm "$deb"
}

function install_jc() {
  local v="1.13.4"
  ! command -v jc &>/dev/null || [[ "$(jc -a | jq -r .version)" != "$v" ]] || return 0
  local deb
  deb="$(mktemp)"
  curl -fsSL "https://jc-packages.s3-us-west-1.amazonaws.com/jc-${v}-1.x86_64.deb" >"$deb"
  sudo dpkg -i "$deb"
  rm "$deb"
}

function install_bat() {
  local v="0.17.1"
  ! command -v bat &>/dev/null || [[ "$(bat --version)" != *" $v" ]] || return 0
  local deb
  deb="$(mktemp)"
  curl -fsSL "https://github.com/sharkdp/bat/releases/download/v${v}/bat_${v}_amd64.deb" > "$deb"
  sudo dpkg -i "$deb"
  rm "$deb"
}


command_exists() {
    hash "$1" &>/dev/null
}
# install git
if command_exists git; then
    echo "git is installed"
else
    echo "WARNING: \"git\" command is not found. Install it first"
    apt-get install -y git
fi

# install curl
if command_exists curl; then
    echo "curl is installed"
else
    echo "WARNING: \"curl\" command is not found. Install it first"
    apt-get install -y curl
fi

# install wget
if command_exists wget; then
    echo "wget is installed"
else
    echo "require wget but it's not installed. Install it first"
    apt-get install -y wget
fi

# install vim stable
if command_exists vim; then
    echo "vim is installed"
else
    echo "require vim but it's not installed. Install it first"
    add-apt-repository ppa:jonathonf/vim
    apt-get update
    apt-get install -y vim
    apt-get install vim-gtk3
fi

# install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install zsh stable
if command_exists zsh; then
    echo "zsh is installed"
else
    echo "require zsh but it's not installed. Install it first"
    apt-get install -y zsh
fi

# install tmux stable
if command_exists tmux; then
    echo "tmux is installed"
else
    echo "require tmux but it's not installed. Install it first"
    apt-get install -y tmux
fi

if command_exists snap; then
    echo "Snap install"
    snap install --beta nvim --classic
fi


install_ripgrep
install_jc
install_bat
install_exa

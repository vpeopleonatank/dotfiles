
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse"

export PAGER="bat"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export PATH=$PATH:/usr/local/go/bin
MANPATH=/usr/local/texlive/2020/texmf-dist/doc/man:$MANPATH;
export MANPATH
INFOPATH=/usr/local/texlive/2020/texmf-dist/doc/info:$INFOPATH;
export INFOPATH
export PATH=$PATH:/usr/local/texlive/2020/bin/x86_64-linux
export PATH=$PATH:/snap/bin

export XDG_DATA_DIRS="${XDG_DATA_DIRS}:/var/lib/snapd/desktop"

export PATH=$PATH:$(go env GOPATH)/bin
export GOPATH=$(go env GOPATH)
export CHEAT_CONFIG_PATH="~/.dotfiles/tool/cheat/conf.yml"
export CHEAT_USE_FZF=true
export GLFW_IM_MODULE=ibus

export CUDA_HOME=/usr/local/cuda
export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
# export PATH="$PATH:/home/vpoat/.cargo/bin"

source $HOME/.cargo/env

HISTFILE=~/.zsh_history
HISTSIZE=999999999
SAVEHIST=$HISTSIZE
setopt SHARE_HISTORY


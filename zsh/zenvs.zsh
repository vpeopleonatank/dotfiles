# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/vpoat/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/vpoat/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/vpoat/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/vpoat/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# <<< conda initialize <<<
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
export PATH=/usr/lib/jvm/jdk-11.0.11/bin:$PATH
# export PATH=/usr/lib/jvm/java-16-openjdk-amd64/bin/:$PATH


source $HOME/.cargo/env

HISTFILE=~/.zsh_history
HISTSIZE=999999999
SAVEHIST=$HISTSIZE
setopt SHARE_HISTORY

WORDCHARS=${WORDCHARS/\/}

LFCD="$HOME/.config/lf/lfcd.sh"                                #  pre-built binary, make sure to use absolute path
if [ -f "$LFCD"  ]; then
        source "$LFCD"
fi

# source $HOME/Downloads/root/bin/thisroot.sh

export PATH=~/.npm-global/bin:$PATH

export FZF_DEFAULT_COMMAND='fdfind'

export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS=' -p /usr/bin/python3 '
export PROJECT_HOME=$HOME/Devel
source /home/vpoat/.local/bin/virtualenvwrapper.sh

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
export ANDROID_SDK_ROOT=$HOME/Android/Sdk

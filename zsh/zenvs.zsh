# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$HOME/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/anaconda3/bin:$PATH"
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
export PATH=$PATH:/snap/bin

export XDG_DATA_DIRS="${XDG_DATA_DIRS}:/var/lib/snapd/desktop"

export PATH=$PATH:$(go env GOPATH)/bin
export GOPATH=$(go env GOPATH)
export CHEAT_CONFIG_PATH="~/.dotfiles/tool/cheat/conf.yml"
export CHEAT_USE_FZF=true
export GLFW_IM_MODULE=ibus

export PATH=/usr/lib/jvm/jdk-11.0.11/bin:$PATH


if [ -f "$HOME/.cargo/env"  ]; then
  source $HOME/.cargo/env
fi

HISTFILE=~/.zsh_history
HISTSIZE=999999999
SAVEHIST=$HISTSIZE
setopt SHARE_HISTORY

WORDCHARS=${WORDCHARS/\/}

LFCD="$HOME/.config/lf/lfcd.sh"                                #  pre-built binary, make sure to use absolute path
if [ -f "$LFCD"  ]; then
        source "$LFCD"
fi

export PATH=~/.npm-global/bin:$PATH

export FZF_DEFAULT_COMMAND='fdfind'

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
export ANDROID_SDK_ROOT=$HOME/Android/Sdk

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

eval "$(gvm 1.19.4)"

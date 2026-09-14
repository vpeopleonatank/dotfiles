export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse"
export CHEAT_CONFIG_PATH="${DOTFILES_ROOT:-$HOME}/cheat/conf.yml"
export CHEAT_USE_FZF=true
export PATH="$HOME/.local/bin:$PATH"

if (( $+commands[rg] )); then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
elif (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
fi

if (( $+commands[bat] )); then
  export PAGER="bat"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

if [[ -x "$HOME/anaconda3/bin/conda" ]]; then
  __conda_setup="$($HOME/anaconda3/bin/conda shell.zsh hook 2>/dev/null)"
  if [[ $? -eq 0 ]]; then
    eval "$__conda_setup"
  elif [[ -r "$HOME/anaconda3/etc/profile.d/conda.sh" ]]; then
    source "$HOME/anaconda3/etc/profile.d/conda.sh"
  fi
  unset __conda_setup
fi

if [[ -r "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi

if (( $+commands[pyenv] )); then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
  if pyenv commands 2>/dev/null | grep -qx 'virtualenv-init'; then
    eval "$(pyenv virtualenv-init -)"
  fi
fi

if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/lf/lfcd.sh" ]]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/lf/lfcd.sh"
fi

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt BANG_HIST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

WORDCHARS=${WORDCHARS/\/}

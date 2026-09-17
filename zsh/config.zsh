if [[ -z ${DOTFILES_ROOT:-} ]]; then
  DOTFILES_ROOT="${${(%):-%N}:A:h:h}"
fi
typeset -g DOTFILES_ROOT

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source "$DOTFILES_ROOT/zsh/zenvs.zsh"

zstyle ':autocomplete:tab:*' insert-unambiguous yes
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm,cmd -w -w"
zstyle ':autocomplete:*' min-delay .3
zstyle ':autocomplete:tab:*' widget-style menu-select
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':fzf-tab:*' switch-group ',' '.'
if (( $+commands[exa] )); then
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
elif (( $+commands[eza] )); then
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
fi

typeset -g DOTFILES_ZHIST_INITIALIZED=0
dotfiles_init_zhist() {
  (( DOTFILES_ZHIST_INITIALIZED )) && return 0
  ZSH_AUTOSUGGEST_STRATEGY=(history)
  # NOTE: use `command -v`, not $+commands. zsh-vi-mode's zvm_exec_commands
  # declares `local commands=...`, which shadows the special `commands`
  # parameter for everything it calls, including zvm_after_init.
  if command -v zhist >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
    local zhist_init
    if zhist_init="$(zhist init -no-arrow-binds 2>/dev/null)" && [[ -n "$zhist_init" ]] && eval "$zhist_init"; then
      local fhistory_select fzf_query
      fhistory_select=${functions[_fhistory_select]}
      if [[ -n "$fhistory_select" ]]; then
        # zhist's picker starts fzf with an empty query. Preserve its widget
        # while seeding fzf from the command line buffer for Ctrl-R.
        fzf_query='fzf --query="$BUFFER" --ansi'
        functions[_fhistory_select]=${fhistory_select/fzf --ansi/$fzf_query}
      fi
      _zsh_autosuggest_strategy_zhist() {
        typeset -g suggestion="$(zhist search -limit 1 -- "$1")"
      }
      ZSH_AUTOSUGGEST_STRATEGY=(zhist)
      unset HISTFILE
      SAVEHIST=0
      DOTFILES_ZHIST_INITIALIZED=1
    fi
  fi
}

# Only plugins that wrap ZLE widgets belong here; zsh-vi-mode must have set up
# its keymaps first. Everything else loads at top level, where the special
# `commands` parameter is not shadowed (see dotfiles_init_zhist).
zvm_after_init() {
  if (( $+functions[znap] )); then
    if command -v fzf >/dev/null 2>&1; then
      znap source junegunn/fzf shell/{completion,key-bindings}.zsh
      znap source Aloxaf/fzf-tab
      znap source urbainvaes/fzf-marks
    fi
    znap source hlissner/zsh-autopair
    znap source zdharma-continuum/fast-syntax-highlighting
  fi

  run-again() {
    zle up-history
    zle accept-line
  }
  zle -N run-again
  bindkey -M viins '^X' run-again
  bindkey -M vicmd '^X' run-again

  if command -v fzf >/dev/null 2>&1; then
    bindkey '^ ' autosuggest-accept
  fi
  dotfiles_init_zhist
}

if [[ -r "$HOME/.zsh/zsh-snap/znap.zsh" ]]; then
  source "$HOME/.zsh/zsh-snap/znap.zsh"
  # Load before zsh-vi-mode: it defers init to the first precmd, and hooks
  # registered from inside that pass are skipped for the first prompt.
  znap source romkatv/powerlevel10k
  znap source zsh-users/zsh-autosuggestions
  znap source zsh-users/zsh-completions
  znap source wfxr/forgit
  znap source zpm-zsh/colors
  znap source zpm-zsh/ls
  znap source MichaelAquilina/zsh-you-should-use
  znap source agkozak/zsh-z
  znap source Tarrasch/zsh-autoenv
  znap source jeffreytse/zsh-vi-mode
else
  dotfiles_init_zhist
fi

EDITOR="${EDITOR:-vi}"
if (( $+commands[nvim] )); then EDITOR=nvim; elif (( $+commands[vim] )); then EDITOR=vim; fi
export EDITOR

if [[ -r "$HOME/.p10k.zsh" ]]; then
  source "$HOME/.p10k.zsh"
fi

source "$DOTFILES_ROOT/zsh/zaliases.zsh"
source "$DOTFILES_ROOT/zsh/zfunctions.zsh"
dotfiles_enable_lazy_nvm

local_config="${DOTFILES_LOCAL_CONFIG:-$DOTFILES_ROOT/zsh/local.zsh}"
if [[ -r "$local_config" ]]; then
  source "$local_config"
fi

if (( $+commands[zoxide] )); then
  if (( $+functions[znap] )); then znap eval zoxide 'zoxide init zsh'; else eval "$(zoxide init zsh)"; fi
fi

if (( $+commands[dotnet] )) && (( $+functions[compdef] )); then
  _dotnet_zsh_complete() {
    local completions=("$(dotnet complete "$words")")
    if [[ -z "$completions" ]]; then
      _arguments '*::arguments: _normal'
      return
    fi
    _values = "${(ps:\n:)completions}"
  }
  compdef _dotnet_zsh_complete dotnet
fi

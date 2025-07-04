if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Zstyles
zstyle ':autocomplete:tab:*' insert-unambiguous yes # Make Tab first insert any common substring, before inserting full completions
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format 'completing %d:'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm,cmd -w -w"

zstyle ':autocomplete:*' min-delay .3 # Wait for a minimum amount of time
#zstyle ':autocomplete:*' min-input 3 # Wait for a minimum amount of input
#zstyle ':autocomplete:*' ignored-input '..##' # Ignore certain inputs eg. don't trigger autocom when word consist solely of ..
zstyle ':autocomplete:tab:*' widget-style menu-select # Do menu selection:
#zstyle ':autocomplete:tab:*' fzf-completion yes # try Fzf's completion before using Zsh's

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'


if [ ! -d "$HOME/.zsh/zsh-snap"  ]; then
    git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git $HOME/.zsh/zsh-snap
fi
source $HOME/.zsh/zsh-snap/znap.zsh

znap source romkatv/powerlevel10k
znap source jeffreytse/zsh-vi-mode
znap source zsh-users/zsh-autosuggestions  # On same line
function zvm_after_init() {
  ZSH_AUTOSUGGEST_STRATEGY=( history  )
  export ZSH_AUTO_SUGGEST_USE_ASYNC=true
  znap eval junegunn/fzf 'command -v fzf >/dev/null 2>&1 || {./install --bin} >/dev/null'
  znap source junegunn/fzf shell/{completion,key-bindings}.zsh
  path=(~[junegunn/fzf]/bin $path .)
  znap source Aloxaf/fzf-tab
  znap source urbainvaes/fzf-marks

  # define function that retrieves and runs last command
  function run-again {
      # get previous history item
      zle up-history
      # confirm command
      zle accept-line
                  
  }

  # define run-again widget from function of the same name
  zle -N run-again
  
  # bind widget to Ctrl+X in viins mode
  bindkey -M viins '^X' run-again 
  # bind widget to Ctrl+X in vicmd mode
  bindkey -M vicmd '^X' run-again

  zle -N pet-select
  bindkey '^[p' pet-select
  function ghq-fzf() {
    local selected_dir=$(ghq list | fzf --query="$LBUFFER")

      if [ -n "$selected_dir"  ]; then
        BUFFER="cd $(ghq root)/${selected_dir}"
        zle accept-line
      fi

      # zle should be before reset-prompt
      zle reset-prompt

  }

  zle -N ghq-fzf
  bindkey "^]" ghq-fzf
  bindkey '^ ' autosuggest-accept
}
 
znap source wfxr/forgit
znap source zpm-zsh/colors
znap source zpm-zsh/ls
znap source hlissner/zsh-autopair
znap source MichaelAquilina/zsh-you-should-use
znap source zdharma-continuum/fast-syntax-highlighting
znap source zsh-users/zsh-completions
znap source agkozak/zsh-z
znap source Tarrasch/zsh-autoenv 
#znap source marzocchi/zsh-notify

znap eval trapd00r/LS_COLORS '{ command -v gdircolors >/dev/null 2>&1  } && { gdircolors -b LS_COLORS } || { dircolors -b LS_COLORS }'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

EDITOR="nvim"
command -v floaterm >/dev/null 2>&1 && EDITOR="floaterm"


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source $HOME/.dotfiles/tool/zsh/zaliases.zsh
source $HOME/.dotfiles/tool/zsh/zfunctions.zsh
source $HOME/.dotfiles/tool/zsh/zenvs.zsh

if [ "$(command -v zoxide)" ]
then
  znap eval zoxide 'zoxide init zsh'
fi

function _switch_cuda {
   v=$1
   export PATH=$PATH:/usr/lib/cuda/bin
   export CUDADIR=/usr/lib/cuda
   export CUDA_HOME=/usr/lib/cuda
   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/cuda/lib64
}
# _switch_cuda 10.1

function tel {
  arg=$1
  add_p=$(echo $arg | cut -d "/" -f 3)
  add=$(echo $add_p | cut -d ":" -f 1)
  port=$(echo $add_p | cut -d ":" -f 2)
  telnet $add $port
}

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# zsh parameter completion for the dotnet CLI

_dotnet_zsh_complete()
{
  local completions=("$(dotnet complete "$words")")

  # If the completion list is empty, just continue with filename selection
  if [ -z "$completions" ]
  then
    _arguments '*::arguments: _normal'
    return
  fi

  # This is not a variable assignment, don't remove spaces!
  _values = "${(ps:\n:)completions}"
}

compdef _dotnet_zsh_complete dotnet


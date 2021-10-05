# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# source $HOME/.dotfiles/tool/zsh/config.zsh

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
function zvm_after_init() {
  ZSH_AUTOSUGGEST_STRATEGY=( history  )
  znap source zsh-users/zsh-autosuggestions  # On same line
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
}
 
znap source wfxr/forgit
znap source zpm-zsh/colors
znap source zpm-zsh/ls
znap source hlissner/zsh-autopair
znap source MichaelAquilina/zsh-you-should-use
znap source zdharma/fast-syntax-highlighting
znap source zsh-users/zsh-completions
znap source agkozak/zsh-z
znap source Tarrasch/zsh-autoenv 
znap source marzocchi/zsh-notify

znap eval trapd00r/LS_COLORS '{ command -v gdircolors >/dev/null 2>&1  } && { gdircolors -b LS_COLORS } || { dircolors -b LS_COLORS }'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# znap eval fuck 'thefuck --alias'
# znap eval pip 'python3 -m pip completion --zsh'
# znap eval kitty 'kitty + complete setup zsh'
# 

# Load the aliases and custon functions and some:
# for file in ~/dotfiles/zsh/{zaliases,zfunctions}; do
# 	[ -r "$file" ] && [ -f "$file" ] && source "$file";
# done
# unset file

EDITOR="nvim"
command -v floaterm >/dev/null 2>&1 && EDITOR="floaterm"


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source $HOME/.dotfiles/tool/zsh/zaliases.zsh
source $HOME/.dotfiles/tool/zsh/zfunctions.zsh
source $HOME/.dotfiles/tool/zsh/zenvs.zsh
# source $HOME/.dotfiles/tool/zsh



# eval "$(mcfly init zsh)"
# eval "$(zoxide init zsh)"

znap eval zoxide 'zoxide init zsh'

# znap eval mcfly 'mcfly init zsh'

eval $(thefuck --alias f)


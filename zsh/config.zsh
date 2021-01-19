# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

  # zmodload zsh/zprof 
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH


# Execute code in the background to not affect the current session
{
  # Compile zcompdump, if modified, to increase startup speed.
  zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
  if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
    zcompile "$zcompdump"
  fi
} &!

 autoload -Uz compinit 
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
fi;


# Path to your oh-my-zsh installation.
export ZSH="$HOME/.dotfiles/oh-my-zsh"

export FZF_BASE="$HOME/.dotfiles/oh-my-zsh/custom/plugins/fzf"
export FZF_DEFAULT_OPTS='--height 70% --border'
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="powerlevel9k/powerlevel9k"
ZSH_THEME=""
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"



# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    github
    zsh-syntax-highlighting
    zsh-autosuggestions
    colored-man-pages
    python
    tmux
    # fzf
    vscode
    vundle
    command-not-found
    web-search
    history
    extract
    copyfile
    zsh-z
    # k
    zshmarks
    )

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


bindkey -v

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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

alias t='tmux'
alias ez='vim ~/.zshrc'
alias lsh='source ~/.zshrc'
alias jl='jupyter-lab'
alias ca='conda activate'
alias cap='conda activate pytorch'
alias gt="bash ~/.scripts/generate_template.sh"
alias countdown='~/git/countdown/countdown'
alias cd_basic_algo_codelearn='cd /mnt/vpoat/Data/Code/algo_merge/contest/codelearn/basic_algo'
alias psudo='sudo env PATH="$PATH"'
fg() {
  git add .
  git commit -m "update"
  git push
}
export PATH=$PATH:/usr/local/go/bin
MANPATH=/usr/local/texlive/2020/texmf-dist/doc/man:$MANPATH;
export MANPATH
INFOPATH=/usr/local/texlive/2020/texmf-dist/doc/info:$INFOPATH;
export INFOPATH
export PATH=$PATH:/usr/local/texlive/2020/bin/x86_64-linux
export PATH=$PATH:/snap/bin
# fix ls directory color
# tw = cd autocompletion directory color
# export LS_COLORS="ow=43;30:tw=1;34:di=1;34:$LS_COLORS"


# zstyle ':completion:*' list-colors 'di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'


export PATH=$PATH:/home/vpoat/.dotfiles/nodejs/bin
alias esl='sudo vim /etc/apt/sources.list'
alias show_opening_port='sudo netstat -tulpn | grep LISTEN'


alias j="jump"
alias s="bookmark"
alias d="deletemark"
alias p="showmarks"
alias l="showmarks"

export XDG_DATA_DIRS="${XDG_DATA_DIRS}:/var/lib/snapd/desktop"
# cp /var/lib/snapd/desktop/applications/code_code.desktop ~/.local/share/applications/

alias youtube-dl-mp3='youtube-dl --extract-audio --audio-format mp3'

alias onenote='~/bin/P3X-OneNote-2020.10.111.AppImage'
alias setclip="xclip -selection c"
alias getclip="xclip -selection c -o"
alias matlab_gpu='/home/vpoat/.scripts/matlab_gpu.sh'
alias make_files='/home/vpoat/.scripts/make_files.sh'
alias grader='/home/vpoat/.scripts/grader.sh'
alias lg='lazygit'
alias gcache='git config --global credential.helper 'cache --timeout 900000''
alias gfcache='git credential-cache exit'
alias n='nvim'
alias piping_help='curl https://ppng.io/help'


  show-process() {
ps -eo size,pid,user,command --sort -size | \
  awk '{ hr=$1/1024 ; printf("%13.2f Mb ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }' |\
  cut -d "" -f2 | cut -d "-" -f1
}

export PATH=$PATH:$(go env GOPATH)/bin
export GOPATH=$(go env GOPATH)

# fpath+=$HOME/.zsh/pure

# autoload -U promptinit; promptinit

# optionally define some options
# PURE_CMD_MAX_EXEC_TIME=10

# turn on git stash status
#prompt pure
#zstyle :prompt:pure:git:stash show yes
# zprof

# fpath+=$HOME/.zsh/pure

#autoload -U promptinit; promptinit
#prompt pure

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source ~/powerlevel10k/powerlevel10k.zsh-theme

# export LS_COLORS="ow=38;5;220;1:tw=1;34:di=1;34:ex=38;5;208;1:$LS_COLORS:ow=38;5;220;1:tw=1;34:di=1;34:ex=38;5;208;1:"
 . "/home/vpoat/.local/share/lscolors.sh"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

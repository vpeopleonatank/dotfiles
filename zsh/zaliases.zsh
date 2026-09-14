alias v='vim'
alias vimdiff='nvim -d'
alias g='git'
alias lg='lazygit'
alias t='tmux'
alias ez='${EDITOR:-vi} ~/.zshrc'
alias lsh='source ~/.zshrc'
alias jl='jupyter-lab'
alias ca='conda activate'
alias cap='conda activate pytorch'
alias lzd='lazydocker'
alias za='zathura'
alias nv='nvim'
alias lv='lvim'
alias qi='quite-intriguing'
alias lazydocker='TERM=screen-256color lazydocker'
alias dcl='docker compose logs -f -t --tail=100'
alias downsub='yt-dlp --sub-lang en --write-auto-sub --sub-format srt --skip-download'
alias downplaylistbest='yt-dlp -f best -ci'

qg() {
  git add .
  git commit -m "update"
  git push
}

tl() {
  local selected
  if (( $# > 0 )); then
    selected=$(tldr --list | fzf --query="$*")
  else
    selected=$(tldr --list | fzf)
  fi
  [[ -n "$selected" ]] && tldr "$selected"
}

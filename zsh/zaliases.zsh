alias v="vim" vimdiff="nvim -d"
alias pt="ptipython"

alias g="git" lg="EDITOR=nvim lazygit"
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
alias lzd='sudo lazydocker'
# alias vno='HOME=$(mktemp -d) vim -u NONE -U NONE -N -i NONE -u $HOME/.dotfiles/tool/vim/.vimrc_server'
alias vno='vim -u $HOME/.dotfiles/tool/vim/.vimrc_server -U NONE -N -i NONE'

alias esl='sudo vim /etc/apt/sources.list'
alias show_opening_port='sudo netstat -tulpn | grep LISTEN'

alias setclip="xclip -selection c"
alias getclip="xclip -selection c -o"
alias matlab_gpu='/home/vpoat/.scripts/matlab_gpu.sh'
alias make_files='/home/vpoat/.scripts/make_files.sh'
alias grader='/home/vpoat/.scripts/grader.sh'
alias lg='lazygit'
alias gcache='git config --global credential.helper 'cache --timeout 900000''
alias gfcache='git credential-cache exit'
alias nv='/usr/local/bin/nvim'
alias piping_help='curl https://ppng.io/help'
alias listening_port='sudo  netstat -tulpn | grep LISTEN'
alias paste_image='xclip -selection clipboard -t image/png -o >'

alias downsub='youtube-dl --sub-lang en --write-auto-sub --sub-format srt  --skip-download '  # Only download sub
alias downplaylistbest='youtube-dl -f best -cit '

fg() {
  git add .
  git commit -m "update"
  git push
}

get_compile_command() {
  mkdir build; cd build;
  cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 ..
  cd ..
  ln -s $(pwd)/build/compile_commands.json $(pwd)/compile_commands.json
}


show-process() {
ps -eo size,pid,user,command --sort -size | \
  awk '{ hr=$1/1024 ; printf("%13.2f Mb ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }' |\
  cut -d "" -f2 | cut -d "-" -f1
}

sync_jupyter() {
  fname="$PWD"/"$1".ipynb
  jupytext --sync $fname
  ipython $fname
}

source_openvino() {
  cd /opt/intel/openvino_2021/inference_engine 
  source /opt/intel/openvino_2021/bin/setupvars.sh
  cd -
}

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

function com {
  g++ -Wall -Wextra -Wshadow -D_GLIBCXX_ASSERTIONS -DDEBUG -ggdb3 -fmax-errors=2 -o $1{,.cpp}
}

function debug {
  if [[ -z "$2" ]] then 
    (echo "run < $1.in" && cat) | gdb -q $1
  else
    (echo "run < $2" && cat) | gdb -q $1
  fi
}

# cd on quit
n ()
{
    # Block nesting of nnn in subshells
    if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi

    # The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
    # To cd on quit only on ^G, remove the "export" as in:
    #     NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    # NOTE: NNN_TMPFILE is fixed, should not be modified
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    nnn "$@"

    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}

kill_unattached()
{
  tmux list-sessions | grep -v attached | awk 'BEGIN{FS=":"}{print $1}' | xargs -n 1 tmux kill-session -t || echo No sessions to kill
}

pet-select () 
{ 
    # temporary fix termbox in tmux
    TERM="${TERM/#tmux/screen}"
    BUFFER=$(pet search --query "$READLINE_LINE");
    READLINE_LINE=$BUFFER;
    READLINE_POINT=${#BUFFER}
}

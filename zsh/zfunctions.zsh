get_compile_command() {
  mkdir -p build || return
  cd build || return
  cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 ..
  cd .. || return
  ln -sf "$(pwd)/build/compile_commands.json" "$(pwd)/compile_commands.json"
}

show-process() {
  ps -eo pid,user,comm | sed 1d | sort -k1n
}

sync_jupyter() {
  local file="$PWD/$1.ipynb"
  jupytext --sync "$file" && ipython "$file"
}

source_openvino() {
  local openvino_root=/opt/intel/openvino_2021
  if [[ ! -r "$openvino_root/bin/setupvars.sh" ]]; then
    print "OpenVINO 2021 is not installed at $openvino_root" >&2
    return 1
  fi
  cd "$openvino_root/inference_engine" || return
  source "$openvino_root/bin/setupvars.sh"
  cd - >/dev/null || return
}

com() {
  g++ -Wall -Wextra -Wshadow -D_GLIBCXX_ASSERTIONS -DDEBUG -ggdb3 -fmax-errors=2 -o "$1"{,.cpp}
}

debug() {
  if [[ -z "$2" ]]; then
    (echo "run < $1.in" && cat) | gdb -q "$1"
  else
    (echo "run < $2" && cat) | gdb -q "$1"
  fi
}

n() {
  if [[ -n "${NNNLVL:-}" && "${NNNLVL:-0}" -ge 1 ]]; then
    echo 'nnn is already running'
    return
  fi
  export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
  nnn "$@"
  if [[ -f "$NNN_TMPFILE" ]]; then
    source "$NNN_TMPFILE"
    rm -f "$NNN_TMPFILE"
  fi
}

kill_unattached() {
  local session
  while IFS= read -r session; do
    [[ -n "$session" ]] && tmux kill-session -t "$session"
  done < <(tmux list-sessions 2>/dev/null | grep -v attached | awk -F: '{print $1}')
}

pet-select() {
  if (( ! $+commands[pet] )); then
    return 1
  fi
  BUFFER=$(pet search --query "$BUFFER")
  CURSOR=${#BUFFER}
}

dotfiles_load_nvm() {
  unfunction nvm node npm npx corepack 2>/dev/null
  [[ -r "$NVM_DIR/nvm.sh" ]] || return 127
  source "$NVM_DIR/nvm.sh"
  [[ -r "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
}

dotfiles_enable_lazy_nvm() {
  if [[ -z ${NVM_DIR:-} ]]; then
    if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/nvm/nvm.sh" ]]; then
      export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
    else
      export NVM_DIR="$HOME/.nvm"
    fi
  fi
  [[ -r "$NVM_DIR/nvm.sh" ]] || return 0

  nvm() { dotfiles_load_nvm && nvm "$@" }
  node() { dotfiles_load_nvm && command node "$@" }
  npm() { dotfiles_load_nvm && command npm "$@" }
  npx() { dotfiles_load_nvm && command npx "$@" }
  corepack() { dotfiles_load_nvm && command corepack "$@" }
}

en_nvm() {
  dotfiles_load_nvm
}

y() {
  local tmp cwd
  tmp=$(mktemp -t yazi-cwd.XXXXXX) || return
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

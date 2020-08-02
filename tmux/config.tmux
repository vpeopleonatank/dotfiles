set -g mouse on
set-option -sa terminal-overrides ',XXX:RGB'
tmux_conf_copy_to_os_clipboard=true # copy and paster with xclip
bind -Tcopy-mode-vi M-y send -X copy-pipe "xclip -i -sel p -f | xclip -i -sel c" \; display-message "copied to system clipboard"
# -- general -------------------------------------------------------------------
set -g default-terminal 'screen-256color' # colors!
setw -g xterm-keys on
set -s escape-time 10                     # faster command sequences
set -sg repeat-time 600                   # increase repeat timeout
set -s focus-events on

set -g prefix2 C-a                        # GNU-Screen compatible prefix
bind C-a send-prefix -2

set -q -g status-utf8 on                  # expect UTF-8 (tmux < 2.2)
setw -q -g utf8 on

set -g history-limit 10000                 # boost history

# reload configuration
bind r source-file ~/.tmux.conf \; display '~/.tmux.conf sourced'

# -- display -------------------------------------------------------------------

set -g base-index 1           # start windows numbering at 1
setw -g pane-base-index 1     # make pane numbering consistent with windows

setw -g automatic-rename on   # rename window to reflect current program
set -g renumber-windows on    # renumber windows when a window is closed

set -g set-titles on          # set terminal title

set -g display-panes-time 800 # slightly longer pane indicators display time
set -g display-time 1000      # slightly longer status messages display time

set -g status-interval 10     # redraw status line every 10 seconds
# -- navigation ----------------------------------------------------------------

# create session
bind C-c new-session

# find session
bind C-f command-prompt -p find-session 'switch-client -t %%'

# split current window horizontally
bind - split-window -v
# split current window vertically
bind _ split-window -h

# pane navigation
bind -r h select-pane -L  # move left
bind -r j select-pane -D  # move down
bind -r k select-pane -U  # move up
bind -r l select-pane -R  # move right
bind > swap-pane -D       # swap current pane with the next one
bind < swap-pane -U       # swap current pane with the previous one

# maximize current pane
bind + run 'cut -c3- ~/.tmux.conf | sh -s _maximize_pane "#{session_name}" #D'

# pane resizing
bind -r H resize-pane -L 2
bind -r J resize-pane -D 2
bind -r K resize-pane -U 2
bind -r L resize-pane -R 2

# force Vi mode
#   really you should export VISUAL or EDITOR environment variable, see manual
set -g status-keys vi
set -g mode-keys vi

# Switching panes with alt
bind -n M-l select-pane -L
bind -n M-h select-pane -R
bind -n M-k select-pane -U
bind -n M-j select-pane -D

# window navigation
unbind n
unbind p
bind -r C-h previous-window # select previous window
bind -r C-l next-window     # select next window
bind Tab last-window        # move to last active window

# toggle mouse
bind m run "cut -c3- ~/.tmux.conf | sh -s _toggle_mouse"


# -- urlview -------------------------------------------------------------------

bind U run "cut -c3- ~/.tmux.conf | sh -s _urlview #{pane_id}"


# -- facebook pathpicker -------------------------------------------------------

bind F run "cut -c3- ~/.tmux.conf | sh -s _fpp #{pane_id}"




# -- vim-tmux-navigator -------------------------------------------

# Smart pane switching with awareness of Vim splits.
# See: https://github.com/christoomey/vim-tmux-navigator
#is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
#    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
#bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
#bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
#bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
#bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
#tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
#if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
#    "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
#if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
#    "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

bind-key -T copy-mode-vi 'C-h' select-pane -L
bind-key -T copy-mode-vi 'C-j' select-pane -D
bind-key -T copy-mode-vi 'C-k' select-pane -U
bind-key -T copy-mode-vi 'C-l' select-pane -R
bind-key -T copy-mode-vi 'C-\' select-pane -l


# Status update interval
set -g status-interval 1

# Basic status bar colors
set -g status-fg "#556572"
set -g status-bg "#293845"

# Left side of status bar
set -g status-left-length 40
set -g status-left "#[fg=#13222e,bg=#9770b2,bold] #S #[fg=#9770b2,bg=#6a7b88,nobold]#[fg=#293845,bg=#6a7b88] #(whoami) #[fg=#6a7b88,bg=#3f4f5b]#[fg=#6a7b88,bg=#3f4f5b] #I:#P #[fg=#3f4f5b,bg=#293845,nobold]"

# Right side of status bar
set -g status-right-length 150
set -g status-right "#[fg=#3f4f5b,bg=#293845]#[fg=#6a7b88,bg=#3f4f5b] %H:%M:%S #[fg=#6a7b88,bg=#3f4f5b]#[fg=#293845,bg=#6a7b88] %d-%b-%y #[fg=#96a8b5,bg=#6a7b88]#[fg=#13222e,bg=#96a8b5,bold] #H "

# Window status
set -g window-status-format "#[fg=#acbecc]#[bg=#293845]  #I:#W#F  "
set -g window-status-current-format "#[fg=#293845,bg=black]#[fg=#b35d8d,nobold] #I:#W#F #[fg=#293845,bg=black,nobold]"

# Window separator
set -g window-status-separator ""

# Window status alignment
set -g status-justify centre

# Pane number indicator
set -g display-panes-colour "#293845"
set -g display-panes-active-colour "#96a8b5"

# Clock mode
set -g clock-mode-colour "#9770b2"
set -g clock-mode-style 24


set -g message-style fg=black,bg="#9770b2"
set -g message-command-style fg=black,bg="#293845"

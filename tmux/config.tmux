set -g mouse on
# set-option -sa terminal-overrides ',XXX:RGB'
tmux_conf_copy_to_os_clipboard=true # copy and paster with xclip
bind -Tcopy-mode-vi M-y send -X copy-pipe "xclip -i -sel p -f | xclip -i -sel c" \; display-message "copied to system clipboard"
# -- general -------------------------------------------------------------------
# set -g default-terminal "tmux-256color"
# set -ga terminal-overrides ",screen-256color:Tc"
set -g default-terminal 'tmux-256color'
# set -ga terminal-overrides ',xterm-256color:Tc'
set -ga terminal-overrides ',alacritty:Tc'
# set -as terminal-overrides ",gnome*:Tc"

set-option -g default-command zsh

setw -g xterm-keys on
set -s escape-time 10                     # faster command sequences
set -sg repeat-time 600                   # increase repeat timeout
set -s focus-events on

# set -g prefix2 C-a                        # GNU-Screen compatible prefix
# bind C-a send-prefix -2
unbind C-b
set-option -g prefix C-q
bind-key C-q send-prefix


set -q -g status-utf8 on                  # expect UTF-8 (tmux < 2.2)
setw -q -g utf8 on

set -g history-limit 10000                 # boost history

# edit configuration
bind e new-window -n "~/.tmux.conf" "\${EDITOR:-nvim} ~/.tmux.conf && tmux source ~/.tmux.conf && tmux display \"~/.tmux.conf sourced\""

# reload configuration
bind r source-file ~/.tmux.conf \; display '~/.tmux.conf sourced'

# -- display -------------------------------------------------------------------

set -g base-index 1           # start windows numbering at 1
setw -g pane-base-index 1     # make pane numbering consistent with windows

#setw -g automatic-rename false   # rename window to reflect current program
set -g allow-rename off
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
bind - split-window -v -c "#{pane_current_path}"
# split current window vertically
bind _ split-window -h -c "#{pane_current_path}"

bind c new-window -c "#{pane_current_path}"

# pane navigation
bind -r h select-pane -L  # move left
bind -r j select-pane -D  # move down
bind -r k select-pane -U  # move up
bind -r l select-pane -R  # move right
bind > swap-pane -D       # swap current pane with the next one
bind < swap-pane -U       # swap current pane with the previous one

# swap window
bind -n C-M-Left { swap-window -t -1; previous-window }
bind -n C-M-Right { swap-window -t +1; next-window }
bind -n M-Left { swap-window -t -1; previous-window }
bind -n M-Right { swap-window -t +1; next-window }

# maximize current pane
bind + run 'cut -c3- ~/.tmux.conf | sh -s _maximize_pane "#{session_name}" #D'

# pane resizing
bind -r H resize-pane -L 20
bind -r J resize-pane -D 7
bind -r K resize-pane -U 7
bind -r L resize-pane -R 20

# force Vi mode
#   really you should export VISUAL or EDITOR environment variable, see manual
set -g status-keys vi
set -g mode-keys vi

# Switching panes with alt
bind -n M-l select-pane -L
bind -n M-h select-pane -R
bind -n M-k select-pane -U
bind -n M-j select-pane -D


bind -n C-M-l next-window
bind -n C-M-h previous-window

# switch windows alt+number
bind-key -n M-1 select-window -t 1
bind-key -n M-2 select-window -t 2
bind-key -n M-3 select-window -t 3
bind-key -n M-4 select-window -t 4
bind-key -n M-5 select-window -t 5
bind-key -n M-6 select-window -t 6
bind-key -n M-7 select-window -t 7
bind-key -n M-8 select-window -t 8
bind-key -n M-9 select-window -t 9

# List tmux windows in colllapsed view
bind-key w choose-tree -Zs

# window navigation
unbind n
unbind p
bind -r C-h previous-window # select previous window
bind -r C-l next-window     # select next window
bind Tab last-window        # move to last active window

# toggle pane
# bind-key ! break-pane -d -n _hidden_pane
bind-key ! break-pane -d
bind-key s join-pane -v -p 35 -s $.1
bind-key v join-pane -h -p 35 -s $.1
# bind-key = resize-pane -Z
bind -n C-M-j resize-pane -Z


# toggle mouse
bind m run "cut -c3- ~/.tmux.conf | sh -s _toggle_mouse"


# -- urlview -------------------------------------------------------------------

bind U run "cut -c3- ~/.tmux.conf | sh -s _urlview #{pane_id}"


# -- facebook pathpicker -------------------------------------------------------

bind F run "cut -c3- ~/.tmux.conf | sh -s _fpp #{pane_id}"

# -- vim-tmux-navigator -------------------------------------------

bind P paste-buffer
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X rectangle-toggle
unbind -T copy-mode-vi Enter
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'xclip -se c -i'
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'xclip -se c -i'

bind-key -T copy-mode-vi 'C-h' select-pane -L
bind-key -T copy-mode-vi 'C-j' select-pane -D
bind-key -T copy-mode-vi 'C-k' select-pane -U
bind-key -T copy-mode-vi 'C-l' select-pane -R
bind-key -T copy-mode-vi 'C-\' select-pane -l

# monitor windows for activity
setw -g monitor-activity on

# don't wait for escape sequences
set -sg escape-time 0

# display pane numbers for longer
set -g display-panes-time 2000

# increase scrollback lines
set -g history-limit 65536

# keybinding to clear history
bind C-k clear-history \; display-message "history cleared"

# C-b ! breaks current pane into separate window
# join a pane/window from the current session into the current window
bind @ command-prompt -p "create pane from:" "join-pane -s ':%%'"

# reload the .tmux.conf file with Ctrl-r
bind C-r source-file ~/.tmux.conf \; display-message "configuration reloaded"

# toggle passthrough of prefix
bind P if-shell "[ \"$(tmux show-options -g prefix)\" = \"prefix C-a\" ]" '\
    set -g prefix C-b; display-message "passthrough enabled"; refresh-client -S; \
    ' '\
    set -g prefix C-a; display-message "passthrough disabled"; refresh-client -S; \
    '

# increase scrollback lines
set -g history-limit 65536

# keybinding to clear history
bind C-k clear-history \; display-message "history cleared"

# C-b ! breaks current pane into separate window
# join a pane/window from the current session into the current window
bind @ command-prompt -p "create pane from:" "join-pane -s ':%%'"

# reload the .tmux.conf file with Ctrl-r
bind C-r source-file ~/.tmux.conf \; display-message "configuration reloaded"

# bind key to run tui app
bind g display-popup -E -xC -yC -w 80% -h 80% -d "#{pane_current_path}" lazygit

# toggle passthrough of prefix
bind P if-shell "[ \"$(tmux show-options -g prefix)\" = \"prefix C-a\" ]" '\
    set -g prefix C-b; display-message "passthrough enabled"; refresh-client -S; \
    ' '\
    set -g prefix C-a; display-message "passthrough disabled"; refresh-client -S; \
    '

# Tokyonight night theme
set -g mode-style "fg=#7aa2f7,bg=#3b4261"

set -g message-style "fg=#7aa2f7,bg=#3b4261"
set -g message-command-style "fg=#7aa2f7,bg=#3b4261"

set -g pane-border-style "fg=#3b4261"
set -g pane-active-border-style "fg=#7aa2f7"

set -g status "on"
set -g status-justify "left"

set -g status-style "fg=#7aa2f7,bg=#1f2335"

set -g status-left-length "100"
set -g status-right-length "100"

set -g status-left-style NONE
set -g status-right-style NONE

set -g status-left "#[fg=#15161E,bg=#7aa2f7,bold] #S #[fg=#7aa2f7,bg=#1f2335,nobold,nounderscore,noitalics]"
set -g status-right "#[fg=#1f2335,bg=#1f2335,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#1f2335] #{prefix_highlight} #[fg=#3b4261,bg=#1f2335,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#3b4261] %Y-%m-%d  %I:%M %p #[fg=#7aa2f7,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#15161E,bg=#7aa2f7,bold] #h "

setw -g window-status-activity-style "underscore,fg=#a9b1d6,bg=#1f2335"
setw -g window-status-separator ""
setw -g window-status-style "NONE,fg=#a9b1d6,bg=#1f2335"
setw -g window-status-format "#[fg=#1f2335,bg=#1f2335,nobold,nounderscore,noitalics]#[default] #I  #W #F #[fg=#1f2335,bg=#1f2335,nobold,nounderscore,noitalics]"
setw -g window-status-current-format "#[fg=#1f2335,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#3b4261,bold] #I  #W #F #[fg=#3b4261,bg=#1f2335,nobold,nounderscore,noitalics]"

# Plugin 
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-cowboy'  # Kill with prefix + *
set -g @continuum-save-interval '0'
set -g @continuum-restore 'on'
set -g @plugin 'tmux-plugins/tmux-prefix-highlight'
set -g @plugin 'jaclu/tmux-menus'

set -g @continuum-restore 'on'

set -g @plugin 'sainnhe/tmux-fzf'

# Press prefix + I(capital i) to fetch plugin
run '~/.tmux/plugins/tpm/tpm'

# dotfiles
A set of nvim, lvim, zsh, and tmux configuration files.

### Basic Installation

- Install git:
```bash
sudo apt install git -y
```
- Then run setup_zsh.sh script to install zsh, Jetbrain Nerdfont and powerline10k automatically
- Close current terminal then reopen it, change terminal font to Jetbrain Nerdfont, logout and relogin user to apply default shell to zsh,(make sure after this step, zsh is default shell)
- Open terminal then `znap` (zsh 's plugins manager) will install plugins,  config powerline10k (this configuration will appear for the first time)
```bash
git clone https://github.com/vpeopleonatank/dotfiles.git $HOME/.dotfiles/tool
bash $HOME/.dotfiles/tool/setup_zsh.sh

```
- Install cli programs (tmux, python3, nodejs, go, lazygit, lazydocker, rust, ripgrep, bat, exa, fdfind, zoxide, neovim, kitty terminal)
```bash
bash $HOME/.dotfiles/tool/install.sh

```
- Symlink and install neovim 's plugins
```bash
sudo bash $HOME/.dotfiles/tool/config.sh

```
After running this step, type `tmux` then Press `Ctrl + q + I` to install tmux 's plugins

- Install lunarvim
```bash
LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
```

### Visualization


<img src='./docs/plot.png'>

### CLI tools
```
fzf
zoxide
pet
```

# dotfiles
A set of nvim, lvim, zsh, and tmux configuration files.

### Basic Installation

- Install git:
```bash
sudo apt install git -y
```
- Then run setup_zsh.sh script to install zsh, Jetbrain Nerdfont and powerline10k automatically
```bash
git clone https://github.com/vpeopleonatank/dotfiles.git $HOME/.dotfiles/tool
bash $HOME/.dotfiles/tool/setup_zsh.sh

```
- Close current terminal then reopen it, change terminal font to Jetbrain Nerdfont, logout and relogin user to apply default shell to zsh,(make sure after this step, zsh is default shell)
- Open terminal then `znap` (zsh 's plugins manager) will install plugins,  config powerline10k (this configuration will appear for the first time)
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
### Install git from source
sudo apt-get install libcurl4-openssl-dev -y
cd /tmp
curl -o git.tar.gz https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.38.1.tar.gz
tar -zxf git.tar.gz
cd git-*
make prefix=/usr/local/
sudo make prefix=/usr/local install

### Neovim common command
- Diff view current file with it in another branch
```bash
:DiffviewOpen [branch_name]  -uno -- %
```

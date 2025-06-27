#!/bin/bash

sudo apt update
sudo apt-get install zsh git -y
chsh -s /bin/zsh || {
        echo "Error happened when i'm tryng to set zsh your default shell"
    }


echo 'source $HOME/.dotfiles/tool/zsh/config.zsh' >$HOME/.zshrc

if [ ! -d $HOME/powerlevel10k ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
else
    echo "powerlevel10k is installed"
fi

sed -i '/CONTENT,VISUAL_IDENTIFIER/d' ~/.p10k.zsh

function install_fonts() {
    fonts_dir="${HOME}/.local/share/fonts"
    if [ ! -d "${fonts_dir}" ]; then
      echo "mkdir -p $fonts_dir"
      mkdir -p "${fonts_dir}"
    else
      echo "Found fonts dir $fonts_dir"
    fi

    for type in Bold Medium Italic 'Bold Italic'; do
	    file_name="JetBrainsMonoNerdFontMono-${type}.ttf"
	  file_path="${HOME}/.local/share/fonts/${file_name}"
	  file_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/${type}/${file_name}"

    if [ ! -e "${file_path}" ]; then
          echo "wget -O $file_path $file_url"
          wget -O "${file_path}" "${file_url}"
      else
    echo "Found existing file $file_path"
      fi;
    done
    echo "fc-cache -f"
    sudo fc-cache -f
}

install_fonts


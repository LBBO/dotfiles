#!/usr/bin/env bash

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo Update submodules
git submodule update --init --recursive

echo Install curl
sudo apt install curl -y

echo
if ! command -v zsh > /dev/null; then
  echo Install zsh
  sudo apt-get install zsh -y
  chsh -s $(which zsh)
else
  echo Zsh already installed
fi

echo
if ! [ -d "$HOME/.oh-my-zsh" ]; then
  echo Install oh-my-zsh
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo Oh-my-zsh already installed
fi

echo
if ! [ -d "$HOME/.nvm" ]; then
  echo "Install nvm (Node Version Manager)"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
else
  echo Nvm already installed
fi

echo
if ! command -v node > /dev/null; then
  echo Install nodejs
  nvm install node
  nvm use node
  # Enable npm update checking
  chown -R $USER:$(id -gn $USER) $HOME/.config
else
  echo Nodejs already installed
fi

echo
if ! command -v diff-so-fancy > /dev/null; then
  echo
  echo Install diff-so-fancy
  npm i -g diff-so-fancy
else
  echo Diff-so-fancy already installed
fi

echo
# Only install VS code if not installed yet and not WSL
if ! command -v code > /dev/null && ! grep -q Microsoft /proc/version > /dev/null; then
  if command -v snap > /dev/null; then
    echo Install VS code using snap
    sudo snap install code --classic
  else
    echo Install VS code via apt-get
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

    sudo apt-get install apt-transport-https
    sudo apt-get update
    sudo apt-get install code # or code-insiders

    rm packages.microsoft.gpg
  fi

else
  echo VS Code already installed
fi

# Install VS Code extensions
cat $BASEDIR/vscode/extensions.txt | while read extension || [[ -n $extension ]];
do
  code --install-extension $extension
done

echo Install unzip
sudo apt install unzip -y

echo install deno
if ! command -v deno > /dev/null; then
  echo Install deno
  curl -fsSL https://deno.land/x/install/install.sh | sh
  sudo ln -s ~/.deno/bin/deno /usr/local/bin/deno
else
  echo Deno already installed
fi

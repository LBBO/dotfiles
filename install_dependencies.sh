#!/usr/bin/env bash

# Script must be executed as root because of package installations
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo Update submodules
git submodule update --init --recursive

echo
if ! command -v zsh > /dev/null; then
  echo Install zsh
  apt-get install zsh
  chsh -s $(which zsh)
else
  echo Zsh already installed
fi

echo
if ! [ -d "$HOME/.oh-my-zsh" ]; then
  echo Install oh-my-zsh
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo Oh-my-zsh already installed
fi

echo
if ! command -v nvm > /dev/null; then
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

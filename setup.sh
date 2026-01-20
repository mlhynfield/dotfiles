#!/bin/bash

if ! brew --version &>/dev/null; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ ! -d ~/dotfiles ]; then
  git clone https://github.com/mlhynfield/dotfiles.git ~/dotfiles
fi

cd ~/dotfiles || exit

git submodule update --init --recursive

brew tap Homebrew/bundle
brew bundle install

rm -rf ~/.zshrc

stow --adopt .

ya pkg install

git remote set-url origin git@github.com:mlhynfield/dotfiles.git

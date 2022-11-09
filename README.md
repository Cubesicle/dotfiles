# Dotfiles

these are my dotfiles woah

## Installation

1. Clone the repo `cd $HOME; git clone --bare https://github.com/Cubesicle/dotfiles.git $HOME/.dotfiles` and be sure to remove any files that are in conflict.
2. Restart zsh in order for the "dots" alias to work.

## Managing the dotfiles

The "dots" alias is just the "git" command but it uses the ".dotfiles" directory to store all the git files and stuff.
For example, `dots pull` does the exact same thing as `git pull` but it uses the bare git directory called ".dotfiles" instead of the ".git" directory.
Using `git pull` will not do anything since the ".git" directory doesn't exist so don't use it.

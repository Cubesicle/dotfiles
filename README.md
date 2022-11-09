# Dotfiles

these are my dotfiles woah

## Installation

1. Set the "dots" alias:
```bash
alias dots="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
```
2. Run this in the terminal:
```bash
# Clone the repository
git clone --bare https://github.com/Cubesicle/dotfiles.git $HOME/.dotfiles

# Hide untracked files
dots config --local status.showUntrackedFiles no

# Checkout content
dots checkout
```
3. Move or remove any files that are in conflict and run `dots checkout` again.
4. ur done.

## Managing the dotfiles

The "dots" alias is just the "git" command but it uses the ".dotfiles" directory to store all the git files and stuff.
For example, `dots pull` does the exact same thing as `git pull` but it uses the bare git directory called ".dotfiles" instead of the ".git" directory.
Using `git pull` will not do anything since the ".git" directory doesn't exist so don't use it.

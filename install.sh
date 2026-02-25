#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/.emacs.d

ln -sf "$DOTFILES/.tmux.conf" ~/.tmux.conf
ln -sf "$DOTFILES/.emacs.d/init.el" ~/.emacs.d/init.el

echo "Dotfiles installed (symlinked)."

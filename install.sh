#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/.emacs.d

ln -sf "$DOTFILES/.tmux.conf" ~/.tmux.conf
ln -sf "$DOTFILES/.emacs.d/init.el" ~/.emacs.d/init.el

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR/.git" ]; then
  git -C "$TPM_DIR" pull --quiet --ff-only
else
  git clone --quiet https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Install tpm plugins. install_plugins requires a tmux server that has loaded
# our config (so TMUX_PLUGIN_MANAGER_PATH is set in its global env). Reuse an
# existing server if one is running; otherwise spin up a throwaway session.
if tmux info >/dev/null 2>&1; then
  tmux source-file ~/.tmux.conf
  "$TPM_DIR/bin/install_plugins" >/dev/null
else
  tmux new-session -d -s __tpm_bootstrap__
  tmux source-file ~/.tmux.conf
  "$TPM_DIR/bin/install_plugins" >/dev/null
  tmux kill-session -t __tpm_bootstrap__
fi

echo "Dotfiles installed (symlinked)."

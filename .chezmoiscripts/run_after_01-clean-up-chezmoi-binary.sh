#!/usr/bin/env bash

# When using the one-line bootstrap installation chezmoi is installed in the
# ~/bin folder. Since we use Homebrew to install it afterwards we can clean
# up this executable
CHEZMOI="~/bin/chezmoi"
if [[ -f "$CHEZMOI" ]]; then
  rm $CHEZMOI
fi

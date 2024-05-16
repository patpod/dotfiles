#!/bin/sh

# When using the one-line bootstrap nstallation chezmoi is installed in the 
# ~/bin folder. Since we use Homebrew to install it afterwards we can clean
# up this executable
CHEZMOI="~/bin/chezmoi"
if [[ -f "$CHEZMOI" ]]; then
  rm $CHEZMOI
fi

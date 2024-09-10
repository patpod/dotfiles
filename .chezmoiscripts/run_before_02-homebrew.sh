#!/usr/bin/env bash

ensureHomebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is not installed. Installing it now."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

ensureHomebrew

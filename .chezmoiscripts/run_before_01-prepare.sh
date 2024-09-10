#!/usr/bin/env bash

if ! command -v git >/dev/null 2>&1; then
  sudo xcode-select -p >/dev/null 2>&1 || xcode-select --install
fi

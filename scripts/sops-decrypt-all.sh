#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

force=false
while [[ "$#" -gt 0 ]]; do
  case "$1" in
  -f | --force)
    force=true
    shift
    ;;
  *)
    echo "Error: Unknown flag '$1'"
    exit 1
    ;;
  esac
done

find . -regextype egrep -regex ".*\/.+\.sops$|.*\/.+\.sops\." -type f | while IFS= read -r filename; do
  decrypted_filename="${filename//.sops./}"
  decrypted_filename="${decrypted_filename%.sops}"

  if [ -f "$decrypted_filename" ]; then
    # Decrypt the encrypted version
    decrypted_temp=$(mktemp)
    trap 'rm -f "$decrypted_temp"' EXIT
    sops --decrypt "$filename" >"$decrypted_temp"

    # Compare the decrypted version with the existing decrypted file
    if cmp -s "$decrypted_filename" "$decrypted_temp"; then
      echo -e "${GREEN}No changes detected. Skipping decryption for file: $filename${NC}"
    else
      if [ "$force" = true ]; then
        mv "$decrypted_temp" "$decrypted_filename"
        echo -e "${RED}File replaced with the decrypted content: $decrypted_filename${NC}"
      else
        echo -e "${RED}Changes for existing files detected. Use -f or --force flag to overwrite $filename${NC}"
      fi
    fi
  else
    # No decrypted file exists, decrypt and create it
    echo -e "${RED}Decrypting file: $filename${NC}"
    sops --decrypt "$filename" >"$decrypted_filename"
  fi
done

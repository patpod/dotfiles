#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

while IFS= read -r path_regex; do
  find . -regextype egrep -regex ".*/$path_regex" -type f | while IFS= read -r path; do
    dir=$(dirname "$path")
    filename=$(basename "$path")

    if [[ "$filename" == *.* ]]; then
      encrypted_filename="${filename%.*}.sops.${filename##*.}"
    else
      encrypted_filename="${filename}.sops"
    fi
    encrypted_path="$dir/$encrypted_filename"

    if [ -f "$encrypted_path" ]; then
      # Decrypt the encrypted file
      decrypted_temp=$(mktemp)
      trap 'rm -f "$decrypted_temp"' EXIT
      sops --decrypt "$encrypted_path" >"$decrypted_temp"

      # Compare the decrypted version to the file on disk
      if cmp -s "$path" "$decrypted_temp"; then
        echo -e "${GREEN}No changes detected. Skipping encryption for file: $path${NC}"
      else
        echo -e "${RED}Changes detected. Re-encrypting file: $path${NC}"
        sops --encrypt "$path" >"$encrypted_path"
      fi

    else
      # No encrypted version exists. Encrypt the file.
      echo -e "${RED}Encrypting file: $path${NC}"
      sops --encrypt "$path" >"$encrypted_path"
    fi
  done
done < <(grep -oP '\s*- path_regex:\s*\K.*' ".sops.yaml")

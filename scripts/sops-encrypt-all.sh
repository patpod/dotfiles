#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

dryrun=false
while [[ "$#" -gt 0 ]]; do
  case "$1" in
  -d | --dryrun)
    dryrun=true
    shift
    ;;
  *)
    echo "Error: Unknown flag '$1'"
    exit 1
    ;;
  esac
done

while IFS= read -r path_regex; do
  find . -regextype egrep -regex ".*/$path_regex" -type f | while IFS= read -r path; do

    # Skip path if it is already an encrypted file
    if [[ "$path" =~ \.sops\. || "$path" =~ \.sops$ ]]; then
      continue
    fi

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
        [ "$dryrun" = false ] && sops --encrypt "$path" >"$encrypted_path"
      fi

    else
      # No encrypted version exists. Encrypt the file.
      echo -e "${RED}Encrypting file: $path${NC}"
      [ "$dryrun" = false ] && sops --encrypt "$path" >"$encrypted_path"
    fi
  done
done < <(grep -oP '\s*- path_regex:\s*\K.*' ".sops.yaml")

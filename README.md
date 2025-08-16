# My Dotfiles

## Encryption
I use [sops](https://getsops.io/) in combination with [age](https://github.com/FiloSottile/age) to encrypt sensitive config values. In order to automatically encrypt/decrypt files with age, sops expects a file `~/.config/sops/age/keys.txt` that contains the age private key. Naturally the file is not checked into the dotfiles repository. The content of the file is stored in Bitwarden under `age key v1`.

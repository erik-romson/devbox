#!/bin/bash
echo
echo Initialize global GIT config
echo
read -p 'Fullt navn: ' user
read -p 'E-post: ' email

# Reset old values

git config --global --unset-all branch.autosetuprebase
git config --global --unset-all push.default
git config --global --unset-all user.name
git config --global --unset-all user.email

# Set new global config

git config --global branch.autosetuprebase always
git config --global push.default current
git config --global user.name "$user"
git config --global user.email "$email"

git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret

echo
echo Current git config:
echo
git config -l

echo
echo Optional - Update your git server with your SSH public key
echo ----------------------------------------------------------
echo
cat ~/.ssh/id_rsa.pub
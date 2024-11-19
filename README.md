# Shutup

A SSH manager writen in perl

It uses simple config file (.shutup) that is basically a list of hosts and pem files ~~or passwords)~~ (which you shouldn't use for security reasons, but you do you)

This config file must be encrypted using GPG and as decrypted in memory when you run the program

# TODO
Some things that I'll might add to the script
  - Changing configurations through the scripts, so that the users doesn't need to manually decrypt the config file to edit it
      - Maybe do something like git commit, open an editor for the user
  - Write a more decent readme, because this one sucks
  - Make sure it is actually secure
      - It is pretty simple right now and relies on other programs to actually do the things, but haxxers are very smart and might find a way to exploit this script somehow

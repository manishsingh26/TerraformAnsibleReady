#! /bin/bash
sudo apt-get update -y
ssh-keygen -t rsa -b 4096 -C "" -P "" -f "key_name.key" -q

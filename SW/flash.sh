#!/bin/bash
git clone https://github.com/jda/pk2cmd.git
cd pk2cmd
make linux
sudo make install 
pk2cmd -PPIC16F887 -M -Y -W -F../main.hex

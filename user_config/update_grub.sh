#!/bin/bash
echo "Updating GRUB settings, please wait..."
grub=$((ls /usr/sbin | grep 'grub2-install') || exit 0)
if [ -z "$grub" ]
then
    grub=$((ls /usr/sbin | grep 'grub-install') || exit 0)
    if [ -z "$grub" ]
    then
        echo "No tools for GRUB was found."
        exit 0
    else
        sudo grub-install /dev/sda
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi    
else
    sudo grub2-install /dev/sda
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
fi
echo "Finished."

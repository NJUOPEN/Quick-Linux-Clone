#!/bin/bash

# A simple script for cleaning log files & cache
# Should be run as root
### Used with specail care!!! ###

function showHelp
{
    echo "Usage: ./clean_log.sh [-h] [-R ROOT_DIR] [-H HOME_DIR]"
    echo
}

ROOT_DIR=
HOME_DIR=

while getopts "hR:H:" arg
do
    case $arg in
        h)
            showHelp
            exit 0
            ;;
        R)
            ROOT_DIR=$OPTARG
            ;;
        H)
            HOME_DIR=$OPTARG
            ;;
        ?)
            echo "Invalid argument"
            showHelp
            exit 1
            ;;
    esac
done

if [ ! -n "$ROOT_DIR" ]; then
    ROOT_DIR=/
fi
if [ ! -n "$HOME_DIR" ]; then
    HOME_DIR=$HOME
fi

echo "ROOT = $ROOT_DIR"
echo "HOME = $HOME_DIR"
echo "Is that right?(y/n)"
read choice
if [ ! "$choice" = "y" ];then
    exit 0
fi

CMD_PATH=$(dirname $0)

# Clean user log
# Note: If run with "sudo", $HOME may represent "/root", 
# or the home of user who run this command!
cd $HOME_DIR
rm .bash_history
rm .sudo_as_admin_successful
rm .xsession-errors*

# Clean user config
rm -R .adobe
rm -R .dbus
rm -R .gstreamer-0.10
rm -R .macromedia
rm -R .pki
rm -R .presage

# Clean user log (Firefox)
cd $HOME_DIR/.mozilla/firefox
rm -R Crash\ Reports/*
rm -R *.default/datareporting/*

# Clean user cache
cd $HOME_DIR/.cache
rm -R mozila/firefox/*
rm -R thumbnails
rm upstart/*
rm -R webkit/*


# Clean root log
cd $ROOT_DIR/root
rm -R .bash_history
rm -R .nano
rm -R .synaptic

# Clean root cache
rm -R .aptitude
rm -R .cache


# Clean tmp
cd $ROOT_DIR/tmp
rm -R *

# Clean system log
cd $ROOT_DIR/var/log
rm -R *

# Clean crash log
cd $ROOT_DIR/var/crash
rm *

# Clean apt cache
cd $ROOT_DIR/var/cache/apt/archives
rm *.deb

# Done
cd $CMD_PATH
echo "Cleaning done."

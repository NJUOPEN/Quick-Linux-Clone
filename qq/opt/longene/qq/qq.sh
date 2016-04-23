#!/bin/bash

# Launch script for QQ 6.9
# Use old version of windows libraries, but native (new) version of wine libs
# Adapt from deb package "wine-tm2013-longeneteam"

set -e
export LANG=zh_CN.utf8

#Longene Dir
LONGENE_DIR=/opt/longene

#Wine Program Main Dir
WINE_DIR=/usr

#WINPREFIX Dir
WINEPREFIX_DIR=$HOME/.longene/qq

#Current App Dir
APP_DIR=$LONGENE_DIR/qq

#Current User
#RUNUSER="`basename $HOME `"
RUNUSER=`whoami`

PACKAGE_NAME=wine-qq6.9


function runhelp
{
    echo "************************************************************************"
    echo "*	Commands:"
    echo "*	-u/--uninstall	Uninstall Wine-QQ if you don't like"
    echo "*	-d/--debug	Open debug channel. Log file is in your home directory"
    echo "*	-h/--help	The fucking help information as now you are reading"
    echo "*	-k/--kill	execute wineserver -k to kill all wine programs"
    echo "*	-reg/--regedit	start regedit editor"
    echo "*	-cfg/--winecfg	start winecfg"
    echo "************************************************************************"
}

function uninstallpackage
{
    echo "*	Remove wine-qq6.9..."
    read -p "*	Are you sure? (Y/N)" ANSW
    if [ "$ANSW" = "Y" -o "$ANSW" = "y" -o -z $ANSW  ];then
	sudo dpkg -P $PACKAGE_NAME
	echo "Removing....."
    else 
	exit 0
    fi
}


function check_owner
{
    WINEPREFIX_DIR_USER=`stat -c %U $WINEPREFIX_DIR`	
    if [ "$RUNUSER" != "$WINEPREFIX_DIR_USER" ];then
	sudo chown $RUNUSER $WINEPREFIX_DIR
	echo "*	Modifying the owner of $WINEPREFIX_DIR"
    fi
}


function check_firstrun
{
    #	echo "Check firstrun...."	
    if [ ! -e $WINEPREFIX_DIR/firstrun ];then
	echo "*	Seems the first time to run. Here we go!"
	if [ ! -d "$HOME/.wine-qq" ];then
		mkdir $HOME/.wine-qq
	fi
	local msi_file
	msi_file=$(ls $HOME/.cache/wine/wine_gecko*.msi)
	if [ -n "$msi_file" ];then
		env WINEPREFIX=$WINEPREFIX_DIR $WINE_DIR/bin/wine msiexec /i $msi_file
	fi
	echo "Bingoo" >$WINEPREFIX_DIR/firstrun
    fi	
}

function check_exist
{
    local PID
    PID=$(ps -C TXPlatform.exe -o pid= || exit 0)    #'exit 0' is to suppress non-zero return value
    if [ -n "$PID" ]
    then    #If there is already another QQ running, kill it
        kill $PID
    fi
}

function runapp
{
    if [ -e "$WINE_DIR/bin/wine" ];then

	if [ -e "$WINEPREFIX_DIR/drive_c/Program Files/Tencent/QQ/Bin/QQ.exe"  ];then
	    check_owner
	    check_firstrun
	    check_exist
	    WINEDEBUG=-all env WINEPREFIX=$WINEPREFIX_DIR $WINE_DIR/bin/wine  $WINEPREFIX_DIR/drive_c/Program\ Files/Tencent/QQ/Bin/QQ.exe

	else
	    echo "*	QQ.exe is not found! Unzip package needed."
	    echo "Unzip ...... Please be patient to wait"
	    mkdir -p $HOME/.longene
	    tar -Jxf $APP_DIR/qq.tar.xz -C $HOME/.longene
	    echo "Done, Enjoy it!"
	    runapp
	fi
    else
	echo "*	Binary file wine is not found! Reinstall the deb package needed."
    fi
}

function debugapp
{
    echo "*	Starting debug channel......."
    echo "*	Log file will be created in your Home:/Longene_tm2013.log"
    echo "*	You can upload the log on our site for help: http://www.longene.org"

    env WINEPREFIX=$WINEPREFIX_DIR $WINE_DIR/bin/wine $WINEPREFIX_DIR/drive_c/Program\ Files/Tencent/QQ/Bin/QQ.exe  >$HOME/QQ6.9.log 2>&1
}

case $1 in 
    "--uninstall"| "-u")
    uninstallpackage
    ;;
    "--debug"| "-d")
    debugapp
    ;;
    "--kill"| "-k")
    env WINEPREFIX=$WINEPREFIX_DIR $WINE_DIR/bin/wineserver -k
    ;;
    "--regedit"| "-reg")
    env WINEPREFIX=$WINEPREFIX_DIR $WINE_DIR/bin/regedit
    ;;
    "--winecfg"| "-cfg")
    env WINEPREFIX=$WINEPREFIX_DIR $WINE_DIR/bin/winecfg
    ;;
    "--help"| "-h")
    runhelp
    ;;
    *)
    if [ -z $1 ];then		
	runapp
    else
	echo "Invalid option:$1"
	runhelp			
    fi
    ;;
esac 

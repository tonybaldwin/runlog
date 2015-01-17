#!/bin/bash

##############################################################
# installation script for runlog                             #
# runners workout log management in bash by tony baldwin     #
# http://tonyb.us/runlog                                     #
# released according to the terms of the GNU GPL v.3 or later#
##############################################################

if [ ! -d "$HOME/bin/" ]; then
	mkdir $HOME/bin/
	PATH=$PATH:/$HOME/bin/
	export PATH
fi

rlpath="$HOME/.runlog/"
editor="/usr/bin/vim"

echo "installing runlog ... "
cp runlog.sh $HOME/bin/runlog
chmod +x $HOME/bin/runlog

echo "Creating config files ... "
echo "# runlog config " > $HOME/.runlog.conf
read -p "Enter your name: " uname
read -p "Preferred distance unit (miles, km): " dunit
read -p "Where do you wish to keep your runlog files? (default ~/.runlog/ If you choose another directory, do not forget trailing slash.): " rlpath
read -p "What is your prefered editor? (default /usr/bin/vim): " editor
read -p "What is your prefered web browser? (i.e. /usr/bin/iceweasel) " browser
echo "uname=$uname" >> $HOME/.runlog.conf
echo "rlpath=$rlpath" >> $HOME/.runlog.conf
echo "editor=$editor" >> $HOME/.runlog.conf
echo "browser=$browser" >> $HOME/.runlog.conf

read -p "Will you use the friendica plugin? (y/n)" fplug
if [[ $fplug = y ]]; then
	read -p "Enter your friendica username (optional): " fuser
	read -p "Enter your friendica password (optional): " fpass
	read -p "Enter the url to your friendica site (optional): " $fsite
	echo "fplug=y" >> $HOME/.runlog.conf
	echo "fuser=$fuser" >> $HOME/.runlog.conf
	echo "fpass=$fpass" >> $HOME/.runlog.conf
	echo "fsite=$fsite" >> $HOME/.runlog.conf
else
	echo "fplug=n0pe" >> $HOME/.runlog.conf
fi

echo "Installation complete."

runlog h
exit

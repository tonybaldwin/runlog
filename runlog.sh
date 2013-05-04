#!/bin/bash

#################################
# runlog - by tony baldwin      #
# http://tonyb.us/runlog        #
# keeping a personal runlog     #
# released according to GPL v.3 #
#################################

filedate=$(date +%Y%m%d%H%M%S)
thismonth=$(date +%Y%m)
tday=$(date +%Y%m%d)


source  ~/.runlog.conf
cd $rlpath

# read entries
if [[ $1 = r ]]; then
	if [[ $2 ]]; then
		cat $2* | less
	else
		for i in $(ls -Rt *.run); do cat $i; done | less
	fi
else
# help
if [[ $1 = h ]]; then
	echo "runlog management system by tony baldwin, http://tonyb.us/runlog
----------- runlog usage ------------
runlog - opens a new runlog file to edit in your editor.
runlog e filename - opens log entry with filename for editing. Must use full filename.
runlog v filename - opens log entry with filename for viewing. Must use full filename.
runlog d filename - delete runlog file with filename.
runlog r - reads all entries (cats all files in the dir, pipes to less)
runlog r yyyymmdd - reads entries from date yyyymmdd. One can specify just yyyymm, or just yyyy, even.
runlog l - lists all runlog entries. Like r, it can be narrowed down with date parameters.
runlog s searchterm - searches for searchterm in run entries.
runlog mo yyyymm - gives a monthly report for month yyyymm 
runlog h - displays this help message.
DATES: YYYYMMDD means 4 digit year, 2 digit month, 2 digit day.
This month is $thismonth, Today is $tday.
TIMES: At this point, the math isn't here to convert seconds/decimals.
Either enter full minutes, or use a decimal value (i.e. for 30min45secs, use 30.75, NOT 30:45).
It's on my todo list...
-------------------------------------
runlog is released according to GPL v. 3"
else
# list entries
if [[ $1 = l ]]; then
	if [[ $2 ]]; then
		ls -1t | grep $2
	else
		ls -1t
	fi
else
# delete an entry
if [[ $1 = d ]]; then
	read -p "Are you certain you wish to delete $2? " dr
	if [[ $dr = y ]]; then
		rm $2
	else
		exit
	fi
else
# view a single entry
if [[ $1 = v ]]; then
	less $2
else
# edit an entry
if [[ $1 = e ]]; then
	$editor $2
else
# search entries
if [[ $1 = s ]]; then
	grep -iw $2 *
else
#create monthly report
if [[ $1 = mo ]]; then
	if [ -e $2.month ]; then
		read -p "Report exists. View or Recreate? (v/r)" po0p
		if [ $po0p = v ] ; then 
			cat $2.month
			exit
		else
			mv $2.month $2.month.bak
		fi
	fi
		ttime=0
		tdist=0
		for di in $(ls $2*.run); do
		grep Distance $di | awk '{ print $2 }' >> $2.distance
		done
		for dis in $(cat $2.distance); do
		tdist=`echo "$tdist+$dis" | bc`
		done
		for ti in $(ls $2*.run); do
		grep Time $ti | awk '{ print $2 }' >> $2.time
		done
		for tim in $(cat $2.time); do
		ttime=`echo "$ttime+$tim" | bc`
		done
		avp=`echo "$ttime / $tdist" | bc`
		echo "---- Monthly Run Report $2 ----" > $2.month
		echo "Total Distance = $tdist
Total Time = $ttime
Average Pace = $avp mins/mile" >> $2.month
		rm $2.distance
		rm $2.time
		cat $2.month
		exit
else
	date=`date`
	read -p "Distance (miles):  " dist
	read -p "Time (minutes, decimal values ok, no seconds, i.e. 20:45 = 20.75): " mins
	read -p "Notes: " notes
	mpm=`echo "$mins / $dist" | bc -l`
	echo -e "\n$date\n\n$dist miles in $mins minutes, \nPace: $mpm min/mile\n-------------------\n$notes\n------------------\n" > $filedate.run
	$editor $filedate.run
# FRIENDICA PLUGIN START
# This bit allows one to post to Friendica (see www.friendica.com), and to the @runner group
# comment out or delete this part if you don't want to use friendica.
if [[ $fplug = y ]]; then 
	read -p "Post to my friendica? (y/n) " post
	if [[ $post = y ]]; then
		echo -e "@runner #running\nposted with runlog - http://tonyb.us/runlog\n----------------\n" >> ~/.runlog/$filedate.run
		ud="$(cat ~/.runlog/$filedate.run)"
		title="Tony's Runlog"
		echo "would you like to crosspost to "
		read -p "statusnet? " snet
		read -p "twitter? " twit
		read -p "facebook? " fb
		read -p "dreamwidth?  " dw
		read -p "livejournal? " lj
		read -p "insanejournal?" ij
		read -p "tumblr? " tum
		read -p "posterous? " pos
		read -p "wordpress? " wp 
		read -p "libertree? " lt
		if [[ $(curl --ssl -u $fuser:$fpass -d "status=$ud&title=$title&ljpost_enable=$lj&ijpost_enable=$ij&posterous_enable=$pos&dwpost_enable=$dw&wppost_enable=$wp&tumblr_enable=$tum&facebook_enable=$fb&twitter_enable=$twit&libertree_enable=$lt:65&statusnet_enable=$snet&source=runlog.sh" $fsite/api/statuses/update.xml | grep error) ]]; then
			echo "Error!"
			exit
		else 
			echo "Success!"
		read -p "Shall we have a look in your a browser now? (y/n): " op
			if [ $op = "y" ]; then
			xdg-open $fsite/u/$fuser
			fi
		fi
	fi
fi
# FRIENDICA PLUGIN END
fi
fi
fi
fi
fi
fi
fi
fi
exit

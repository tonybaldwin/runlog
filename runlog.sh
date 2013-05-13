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
runlog yr yyyy - gives a yearly report for year yyyy (such as runlog yr 2013)
runlog h - displays this help message.
DATES: YYYYMMDD means 4 digit year, 2 digit month, 2 digit day.
This month is $thismonth, Today is $tday.
TIMES: Enter time, including hours HH:MM:SS, even if you are doing short runs, under an hour.
i.e. for a 23minute 15second run: 00:23:15
Otherwise the math will be all wrong.
REPORTS: yearly and monthly reports will give you data for
Total no. of workouts, total distance, total time, average distance, average page
for the time period in question, to date.
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
		fi
	fi
		ttime=0
		tdist=0
		noruns=0
		for i in $(ls $2*.run); do noruns=$((noruns+1)); done
		for di in $(ls $2*.run); do
		grep Distance $di | awk '{ print $2 }' >> $2.distance
		done
		for dis in $(cat $2.distance); do
		tdist=`echo "$tdist+$dis" | bc`
		done
		for ti in $(ls $2*.run); do
		rtime=`grep Time $ti | awk '{ print $2 }'`
		timesex=`echo "$rtime" | awk -F: '{ print ($1*3600) +($2*60) + $3 }'`
		echo $timesex >> $2.time
		done
		for tim in $(cat $2.time); do
		ttime=`echo "$ttime+$tim" | bc -l`
		tmins=`date -d "1970-1-1 0:00 +$ttime.00 seconds" "+%H:%M:%S"`
		done
		avpsex=`echo "$ttime / $tdist" | bc -l`
		avpmins=`date -d "1970-1-1 0:00 +$avpsex seconds" "+%M:%S"`
		avdist=`echo "$tdist/$noruns" | bc -l`
		echo "---- $uname's Monthly Run Report $2 ----" > $2.month
		echo  "Total workouts = $noruns
Total Distance = $tdist
Total Time = $tmins
Average Distance = $avdist
Average Pace = $avpmins mins/$dunit
-------------------------------------" >> $2.month
		rm $2.distance
		rm $2.time
		cat $2.month
		exit
else
#create yearly report
if [[ $1 = yr ]]; then
	if [ -e $2.year ]; then
		read -p "Report exists. View or Recreate? (v/r)" po0p
		if [ $po0p = v ] ; then 
			cat $2.year
			exit
		fi
	fi
		ttime=0
		tdist=0
		noruns=0
		for i in $(ls $2*.run); do noruns=$((noruns+1)); done
		for di in $(ls $2*.run); do
		grep Distance $di | awk '{ print $2 }' >> $2.distance
		done
		for dis in $(cat $2.distance); do
		tdist=`echo "$tdist+$dis" | bc`
		done
		for ti in $(ls $2*.run); do
		rtime=`grep Time $ti | awk '{ print $2 }'`
		timesex=`echo "$rtime" | awk -F: '{ print ($1*3600) +($2*60) + $3 }'`
		echo $timesex >> $2.time
		done
		for tim in $(cat $2.time); do
		ttime=`echo "$ttime+$tim" | bc -l`
		tmins=`date -d "1970-1-1 0:00 +$ttime.00 seconds" "+%H:%M:%S"`
		done
		avpsex=`echo "$ttime / $tdist" | bc -l`
		avpmins=`date -d "1970-1-1 0:00 +$avpsex seconds" "+%M:%S"`
		avdist=`echo "$tdist/$noruns" | bc -l`
		echo "---- $uname's Yearly Run Report $2 ----" > $2.year
		echo "Total workouts = $noruns
Total Distance = $tdist
Total Time = $tmins
Average Distance = $avdist
Average Pace = $avpmins mins/$dunit
-------------------------------------" >> $2.year
		rm $2.distance
		rm $2.time
		cat $2.year
		exit
else
	date=`date`
	read -p "Distance ($dunit):  " dist
	read -p "Time (HH:MM:SS, include hours, even if 00): " rtime
	read -p "Weight: " weight
	read -p "Notes: " notes
	timsex=`echo "$rtime" | awk -F: '{ print ($1*3600) + ($2*60) + $3 }'`
	pacesex=`echo "$timsex/$dist" | bc -l`
	wchange=`echo "$weight - $sweight" | bc -l`
	calsburned=`echo "0.7568 * $weight * $dist" | bc -l`
	pacemin=`date -d "1970-1-1 0:00 +$pacesex seconds" "+%M:%S"`
	echo -e "\n$date\n\nDistance: $dist $dunit \nTime $rtime \nPace: $pacemin min/$dunit\nWeight: $weight ($wchange from initial $sweight)\nCalories: $calsburned\n-------------------\n$notes\n------------------\n" > $filedate.run
	$editor $filedate.run
# FRIENDICA PLUGIN START
# This bit allows one to post to Friendica (see www.friendica.com), and to the @runner group
# Only implemented if the $fplug value in ~/.runlog.conf = y
# and, of course, the proper friendica parameters (user:pass, site.url) are present in same .conf file
if [[ $fplug = y ]]; then 
	read -p "Post to my friendica? (y/n) " post
	if [[ $post = y ]]; then
		echo -e "@runner #running\nposted with runlog - http://tonyb.us/runlog\n----------------\n" >> $rlpath/$filedate.run
		ud="$(cat ~/.runlog/$filedate.run)"
		title="$uname's Runlog"
		echo "would you like to crosspost to "
		read -p "statusnet? " snet
		read -p "twitter? " twit
		read -p "facebook? " fb
		read -p "dreamwidth?  " dw
		read -p "livejournal? " lj
		read -p "insanejournal?" ij
		read -p "tumblr? " tum
		read -p "wordpress? " wp 
		read -p "libertree? " lt
		if [[ $(curl -k -u $fuser:$fpass -d "status=$ud&title=$title&ljpost_enable=$lj&ijpost_enable=$ij&dwpost_enable=$dw&wppost_enable=$wp&tumblr_enable=$tum&facebook_enable=$fb&twitter_enable=$twit&libertree_enable=$lt:65&statusnet_enable=$snet&source=runlog.sh" $fsite/api/statuses/update.xml | grep error) ]]; then
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
fi
exit

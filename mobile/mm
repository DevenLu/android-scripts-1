#!/data/local/bin/bash
# -*- encoding: utf8 -*-
###############################################################
##
## Name:		Monkey Script
## Project:		http://code.dapps.douban.com/zhangxiaoke/android-test
## Version:		1.0 2013.09.03
## Version:		1.1 2013.09.05
## Version:		1.2 2013.09.06
## Version:		1.3 2013.09.30 add run on phone support
## Author:		zhangxiaoke@douban.com
##
###############################################################
function run_monkey()
{
	EVENTS=90000000
	if [ $DEBUG == true ];then
		EVENTS=20	
	fi
	THROTTLE=200
	SEED=`date "+%s"`
	DATE=`date "+%Y%m%d"`
	SDCARD=/sdcard/monkey/logs
	DIR=${SDCARD}/${DATE}
	FILE=${DIR}.txt
	TIME=`date "+%H%M%S"`
	LOG_DIR=${DIR}/${TIME}

	mkdir -p ${LOG_DIR}
	echo "Seed:" ${SEED}
	echo "Events:" ${EVENTS}
	echo "Logs:" ${LOG_DIR}

	CMD="monkey -p ${PACKAGE} -s ${SEED} --throttle ${THROTTLE} -v -v -v ${EVENTS} -pct-touch 60% --pct-motion 20% --pct-anyevent 20% --ignore-security-exceptions --kill-process-after-error --monitor-native-crashes >${LOG_DIR}/monkey.txt"
	echo ${CMD}>${LOG_DIR}/cmd.txt
	echo "Monkey command: (\""${CMD}\"\)
	echo "Monkey running..."
	monkey -p ${PACKAGE} -s ${SEED} --throttle ${THROTTLE} -v -v -v ${LOOP} -pct-touch 50% --pct-motion 20% --pct-anyevent 30% --ignore-security-exceptions --kill-process-after-error --monitor-native-crashes >${LOG_DIR}/monkey.txt
	echo "Monkey finished."
	echo "Collecting traces..."
	cat /data/anr/traces.txt>${LOG_DIR}/traces.txt
	echo "Collecting cpuinfo..."
	cat /proc/cpuinfo>${LOG_DIR}/cpuinfo.txt
	echo "Collecting meminfo..."
	cat /proc/meminfo>${LOG_DIR}/meminfo.txt
	echo "Collecting dumpsys info..."
	dumpsys meminfo ${PACKAGE}>${LOG_DIR}/dumpmeminfo.txt
	if [ ${DEBUG} == false ];then
		echo "Collecting bugreport..."
		bugreport>>${LOG_DIR}/bugreport.txt	
	fi

}
DEBUG=false
PACKAGE=com.douban.shuo
LOOP=10000
SLEEP=10
PROGNAME=`basename $0`
if [ -z "$1" ] || [ "$1" != "start" ]; then
	echo "Usage: ${PROGNAME} start"
	exit
fi
if [ -n "$2" ] && [ "$2" = "debug" ]; then
	DEBUG=true
	LOOP=3
	SLEEP=5
fi

echo "====== Monkey Script ======"
echo "Debug:" ${DEBUG}
echo "Package:" ${PACKAGE}
echo "Loop:" ${LOOP}
cd ${PWD}

for((i=1;i<=${LOOP};i++));
do
	echo ""
	echo "Monkey Start, Loop $i"
	run_monkey
	echo "Sleep 10s for next loop..."
	sleep ${SLEEP}
	echo "Monkey End, Loop $i"
	echo ""
done



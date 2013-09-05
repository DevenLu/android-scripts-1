# -*- encoding: utf8 -*-
#!/bin/bash
###############################################################
##
## Name:		Monkey Script
## Project:		http://code.dapps.douban.com/zhangxiaoke/android-test
## Version:		1.0 2013.09.03
## Version:		1.1 2013.09.05
## Author:		zhangxiaoke@douban.com
##
###############################################################
function run_monkey()
{
	EVENTS=1000000
	if [ $DEBUG == true ];then
		EVENTS=20	
	fi
	THROTTLE=200
	SEED=`date "+%s"`
	DATE=`date "+%Y%m%d"`
	DIR=logs/${DATE}
	TIME=`date "+%H%M%S"`
	LOG_DIR=${DIR}/${TIME}

	mkdir -p ${LOG_DIR}
	echo "Seed:" ${SEED}
	echo "Events:" ${EVENTS}
	echo "Logs:" ${LOG_DIR}

	CMD="adb -s ${DEVICE} shell monkey -p ${PACKAGE} -s ${SEED} --throttle ${THROTTLE} -v -v -v ${EVENTS} -pct-touch 60% --pct-motion 20% --pct-anyevent 20% --ignore-security-exceptions --kill-process-after-error --monitor-native-crashes >${LOG_DIR}/monkey.txt"
	echo ${CMD}>${LOG_DIR}/cmd.txt
	echo "Monkey running..."
	echo "Monkey command: (\""${CMD}\"\)
	adb -s ${DEVICE} shell monkey -p ${PACKAGE} -s ${SEED} --throttle ${THROTTLE} -v -v -v ${LOOP} -pct-touch 60% --pct-motion 20% --pct-anyevent 20% --ignore-security-exceptions --kill-process-after-error --monitor-native-crashes >${LOG_DIR}/monkey.txt
	echo "Monkey finished."
	echo "Collecting traces..."
	adb -s ${DEVICE} shell cat /data/anr/traces.txt>${LOG_DIR}/traces.txt
	echo "Collecting cpuinfo..."
	adb -s ${DEVICE} shell cat /proc/cpuinfo>${LOG_DIR}/cpuinfo.txt
	echo "Collecting meminfo..."
	adb -s ${DEVICE} shell cat /proc/meminfo>${LOG_DIR}/meminfo.txt
	echo "Collecting dumpsys info..."
	adb -s ${DEVICE} shell dumpsys meminfo ${PACKAGE}>${LOG_DIR}/dumpmeminfo.txt
	if [ ${DEBUG} == false ];then
		echo "Collecting bugreport..."
		adb -s ${DEVICE} bugreport>>${LOG_DIR}/bugreport.txt	
	fi
}

DEBUG=false
PACKAGE=com.douban.shuo
LOOP=10000
SLEEP=10
#echo "$# parameters"
#echo "Parameters:" "$@";
PROGNAME=`basename $0`
if [ -z $1 ] || [ $1 != "start" ]; then
	echo "Usage: ${PROGNAME} start"
	exit
fi
if [ $2 == "debug" ]; then
	DEBUG=true
	LOOP=2
	SLEEP=2
fi

DEVICE=`adb devices | awk 'NR>1 {print $1}'`
if [ -z ${DEVICE} ]; then
	echo "No device connected, quit."
	exit
fi
echo "====== Monkey Script ======"
echo "Debug:" ${DEBUG}
echo "Device:" ${DEVICE}
echo "Package:" ${PACKAGE}
echo "Loop:" ${LOOP}
cd ${PWD}
for((i=1;i<=${LOOP};i++));
do
	echo ""
	echo "Monkey Start, Loop $i"
	run_monkey
	echo "Sleep 10s for next monkey loop..."
	sleep ${SLEEP}
	echo "Monkey End, Loop $i"
	echo ""
done



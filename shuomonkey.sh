#!/bin/bash
# -*- encoding: utf8 -*-
###############################################################
##
## Name:		Monkey Script
## Project:		http://code.dapps.douban.com/zhangxiaoke/android-test
## Version:		1.0 2013.09.03
## Version:		1.1 2013.09.05
## Version:		1.2 2013.09.06
## Author:		zhangxiaoke@douban.com
##
###############################################################
function check_device()
{
	DEVICE=`adb devices | awk 'NR>1 {print $1}'`
	if [ -z ${DEVICE} ]; then
		#echo "No device connected, quit."
		#exit
		return 1
	else
		return 0
	fi
	return ${DEVICE}
}
function stop_monkey()
{
	MONKEY_PID=`adb shell ps | grep monkey | awk '{print $2}'`
	adb shell kill ${MONKEY_PID}
}
function run_monkey()
{
	EVENTS=90000000
	if [ $DEBUG == true ];then
		EVENTS=20	
	fi
	THROTTLE=200
	SEED=`date "+%s"`
	DATE=`date "+%Y%m%d"`
	DIR=logs/${DATE}
	FILE=${DIR}.txt
	TIME=`date "+%H%M%S"`
	LOG_DIR=${DIR}/${TIME}

	mkdir -p ${LOG_DIR}
	echo "Seed:" ${SEED}
	echo "Events:" ${EVENTS}
	echo "Logs:" ${LOG_DIR}

	CMD="adb -s ${DEVICE} shell monkey -p ${PACKAGE} -s ${SEED} --throttle ${THROTTLE} -v -v -v ${EVENTS} -pct-touch 20% --pct-motion 30% --pct-majornav 20% --pct-syskeys 5% --pct-nav 10% --pct-appswitch 5% --pct-anyevent 10% --ignore-security-exceptions --kill-process-after-error --monitor-native-crashes >${LOG_DIR}/monkey.txt"
	echo ${CMD}>${LOG_DIR}/cmd.txt
	echo "Monkey command: (\""${CMD}\"\)
	echo "Monkey running..."
	adb -s ${DEVICE} shell monkey -p ${PACKAGE} -s ${SEED} --throttle ${THROTTLE} -v -v -v ${EVENTS} -pct-touch 20% --pct-motion 30% --pct-majornav 20% --pct-syskeys 5% --pct-nav 10%  --pct-appswitch 5% --pct-anyevent 10% --ignore-security-exceptions --kill-process-after-error --monitor-native-crashes >${LOG_DIR}/monkey.txt
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
	echo "Collecting fatal exceptions..."
	echo "---------------------------" >> ${FILE}
	echo "${TIME} Crashes: " >> ${FILE}
	grep  -A 10 -B 3 -inr FATAL ${LOG_DIR} >> ${FILE}
	echo " " >> ${FILE} 

}

#echo "$# parameters"
#echo "Parameters:" "$@";
PROGNAME=`basename $0`

if [ -z "$1" ]; then
	echo "Usage: ${PROGNAME} start/stop [debug]"
	exit
fi

if [ "$1" == "stop" ]; then
	stop_monkey
	echo "monkey is stopped."
	exit
fi

if [ "$1" != "start" ]; then
	echo "Usage: ${PROGNAME} start/stop [debug]"
	exit
fi

adb devices
check_device
if [ "$?" -eq 1 ]; then
    echo "No device connected, quit"
	break
fi

DEBUG=false
PACKAGE=com.douban.shuo
LOOP=90000000
SLEEP=10

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
	#check_device
	#if [ "$?" -eq 1 ]; then
    #	echo "No device connected, quit"
	#	break
	#else
    #	echo "Device:" ${DEVICE}
	#fi

	check_device
	while [ "$?" -eq 1 ]; do
    	echo "No device connected."
		echo "Will check 5s later, waiting..."
		sleep 5
		check_device
	done

	echo ""
	echo "Monkey Start, Loop $i"
	run_monkey
	echo "Sleep 10s for next loop..."
	sleep ${SLEEP}
	echo "Monkey End, Loop $i"
	echo ""
done



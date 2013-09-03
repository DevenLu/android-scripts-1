#!/bin/bash
###############################################################
#########
######### Name:		Monkey Script
######### Project:	http://code.dapps.douban.com/zhangxiaoke/android-test
######### Version:	1.0
######### Date:		2013.09.03
######### Author:	zhangxiaoke@douban.com
#########
###############################################################
function run_monkey()
{
	echo ""
	echo "======Monkey Start======"

	DEBUG_LOOPS=100
	MONKEY_LOOPS=1000000
	LOOP=${DEBUG_LOOPS}
	THROTTLE=200
	SEED=`date "+%s"`
	DATE=`date "+%Y%m%d"`
	DIR=logs/${DATE}
	TIME=`date "+%H%M%S"`
	LOG_DIR=${DIR}/${TIME}
	mkdir -p ${LOG_DIR}
	echo "Package:" ${PACKAGE}
	echo "Seed:" ${SEED}
	echo "Events:" ${LOOPS}
	echo "Logs:" ${LOG_DIR}

	CMD="adb -s ${DEVICE} shell monkey -p ${PACKAGE} -s ${SEED} --throttle ${THROTTLE} -v -v -v ${LOOP} -pct-touch 60% --pct-motion 20% --pct-anyevent 20% --ignore-security-exceptions --kill-process-after-error --monitor-native-crashes >${LOG_DIR}/monkey.txt"
	echo "Command: \""${CMD}\"
	echo ${CMD}>${LOG_DIR}/cmd.txt
	echo "Monkey running..."
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
	echo "Collecting bugreport..."
	adb -s ${DEVICE} bugreport>>${LOG_DIR}/bugreport.txt

	echo "======Monkey END======"
	echo ""
}

PACKAGE=com.douban.shuo
DEVICE=`adb devices | awk 'NR>1 {print $1}'`

echo "$# parameters"
echo "$@";
cd ${PWD}
echo "Dir:" ${PWD}
echo "Device:" ${DEVICE}
for((;;))
do
	run_monkey
done

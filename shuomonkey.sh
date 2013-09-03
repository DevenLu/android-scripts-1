#!/bin/bash

function device()
{
    devIndex=`expr "$1" + 1`
    adb devices | head -$devIndex | tail -n 1 | awk '{print $1}'
}

function monkey(package,loops)
{
	echo ""
	echo "======Monkey Start======"

	DEBUG_LOOPS=500
	MONKEY_LOOPS=100000
	LOOPS=${MONKEY_LOOPS}
	THROTTLE=100
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

	echo "Monkey running..."
	adb -s ${DEVICE} shell monkey -p ${PACKAGE} -s ${SEED} \ 
	--throttle ${THROTTLE} -v -v -v ${LOOPS} -pct-touch 60% \ 
	--pct-motion %20 --pct-anyevent %20 --ignore-security-exceptions \ 
	--kill-process-after-error --monitor-native-crashes \ 
	>${LOG_DIR}/monkey.txt
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

echo "$# parameters"
echo "$@";
cd ${PWD}
PACKAGE=com.douban.shuo
DEVICE=`adb devices | awk 'NR>1 {print $1}'`
echo "Dir:" ${PWD}
echo "Device:" ${DEVICE}
monkey

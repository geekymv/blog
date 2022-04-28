#!/bin/bash
export JAVA_HOME=/usr/local/jdk1.8.0_131
export PATH=$PATH:$JAVA_HOME/bin

APP_NAME=$2
PORT=$3

usage(){
    echo "Usage: sh 执行脚本.sh [start|stop|restart|status]"
    exit 1
}

check_appname(){
    if [ "${APP_NAME}" = "" ];then
        echo "未输入应用名"
        exit 1
    fi
}

check_port(){
    if [ "${PORT}" = "" ];then
        echo "未输入端口号，将使用程序内部提供的端口"
    fi
}

#检查程序是否在运行
is_exist(){
  pid=`ps -ef|grep java|grep $APP_NAME|grep -v grep|awk '{print $2}' `
  #如果不存在返回1，存在返回0
  if [ -z "${pid}" ]; then
    return 1
  else
    return 0
  fi
}

#启动方法
start(){
  is_exist
  if [ $? -eq "0" ]; then
    echo "${APP_NAME} is already running. pid-${pid} ."
  else
    if [ -z "${PORT}" ]; then
      nohup java -jar -Dspring.profiles.active=test -Xms1G -Xmx1G  $APP_NAME > /dev/null 2>&1 &
    else	
      nohup java -Dserver.port=${PORT} -jar -Dspring.profiles.active=test -Xms1G -Xmx1G $APP_NAME > /dev/null 2>&1 &
    fi
  fi
}

#停止方法
stop(){
  is_exist
  if [ $? -eq "0" ]; then
    kill -9 $pid
  else
    echo "${APP_NAME} is not running"
  fi
}

#输出运行状态
status(){
  is_exist
  if [ $? -eq "0" ]; then
    echo "${APP_NAME} is running. Pid is ${pid}"
  else
    echo "${APP_NAME} is NOT running."
  fi
}

#重启
restart(){
  stop
  start
}

#根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$1" in
  "start")
    check_appname
    check_port
    start
    ;;
  "stop")
    check_appname
    stop
    ;;
  "status")
    check_appname
    status
    ;;
  "restart")
    check_appname
    restart
    ;;
  *)
    usage
    ;;
esac

#!/bin/sh

echo hello

#
if [ ! -f './load.sh' ] ; then
   echo "Make sure current working directory is where load.sh exists";
   exit -1;
fi

CP=recordloader.jar
CP=$CP:xcc.jar
CP=$CP:xpp3-1.1.4c.jar

US=admin
PASS='Windy2010!'
PORT=$1

echo Port is $1

CONNECTION_STRING=xcc://$US:$PASS@localhost:$PORT
java -Xmx256m \
    -cp $CP \
    -DCONNECTION_STRING=$CONNECTION_STRING \
    -DINPUT_PATH=../marklogic-data \
    com.marklogic.ps.RecordLoader recordloader.properties 


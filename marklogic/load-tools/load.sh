#!/bin/sh

#

CP=recordloader.jar
CP=$CP:xcc.jar
CP=$CP:xpp3-1.1.4c.jar

java -Xmx256m -cp $CP com.marklogic.ps.RecordLoader recordloader.properties

# end recordloader.sh
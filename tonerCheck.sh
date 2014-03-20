#!/bin/bash

# User variables.
SUBNET='192.168.1'         # Do not include last octet, or decimal.
EMAIL='admin@example.com'  # Email address to recive report.

# Script variables.
HOSTNAME=`hostname -s`
SCRIPT="${0}"
TMPFILE="/tmp/newTonerReport.txt"
TODAY=`date +%Y%m%d`
NICEDATE=`date +%Y-%m-%d`
COUNTER=0

# The dirty work.
echo "New Cartridge Report for $TODAY" > $TMPFILE
echo "" >> $TMPFILE
for i in {1..254}
do
  #HP M1212nf, HP P1606dn
  CARTDATE1=`curl --max-time 1 -s "http://$SUBNET.$i/SSI/supply_status.htm" | grep -A1 -e "First Install Date" | tr "<" "\n" | tr ">" "\n" | tail -n3 | head -n1 | tr -d ' '`
  #HP P2035n
  CARTDATE2=`curl --max-time 1 -s "http://$SUBNET.$i/SSI/supply_status.htm" | grep -A1 -e "First Install Date" | tr "<" "\n" | tr ">" "\n" | tail -n5 | head -n1 | tr -d ' '`
  #HP P2055dn
  CARTDATE3=`curl --max-time 1 -s "http://$SUBNET.$i/hp/device/supply_status.htm" | grep -A1 -e "First Install Date" | tr "<" "\n" | tr ">" "\n" | tail -n3 | head -n1 | tr -d ' '`
  #HP 3027
  CARTDATE4=`curl --max-time 3 -k -s "https://$SUBNET.$i/hp/device/this.LCDispatcher?nav=hp.Supplies" | grep -A2 -e "First Install Date" | tr "<" "\n" | tr ">" "\n" | tail -n5 | head -n1 | tr -d ' '`
  #HP M1536dnf
  CARTDATE5=`curl --max-time 1 -s "http://$SUBNET.$i/info_suppliesStatus.html?tab=Status&menu=SupplyStatus" | grep -A3 -e "First Install Date" | tail -n1 | tr -d ' '`
  #echo "$SUBNET.$i: $CARTDATE1 $CARTDATE2 $CARTDATE3 $CARTDATE4 $CARTDATE5"
  if [ "$CARTDATE1" == "$TODAY" ] || [ "$CARTDATE2" == "$TODAY" ] || [ "$CARTDATE3" == "$TODAY" ] || [ "$CARTDATE4" == "$TODAY" ] || [ "$CARTDATE5" == "$TODAY" ]
  then
    PRINTERHOSTNAME=`curl -s http://$SUBNET.$i/SSI/network_summary.htm | grep -A1 -e "Host Name" | tr "<" "\n" | tr ">" "\n" | tail -n3 | head -n1`
    COUNTER=$((COUNTER+1))
    echo "$PRINTERHOSTNAME ($SUBNET.$i)" >> $TMPFILE
  fi
done
echo "" >> $TMPFILE
echo "" >> $TMPFILE
echo "Generated automaticaly by $HOSTNAME:$SCRIPT" >> $TMPFILE

mail -s "New Cartridge Report for $NICEDATE ($COUNTER)" $EMAIL < $TMPFILE
rm $TMPFILE

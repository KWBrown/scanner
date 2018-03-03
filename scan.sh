#!/bin/bash

#Take in a range of IPv4 addresses from arguments
ip_begin=$1
ip_end=$2

#Assuming class C take last octet for the host, first three for network
host1=`echo $ip_begin | cut -d . -f 4`
host2=`echo $ip_end | cut -d . -f 4`
net=`echo $ip_begin | cut -d . -f 1-3`

#Array for Successful Pings
ip_arr=()
#echo $net
#echo $host1 $host2

#Test layer 3 connection
for((i=$host1; i<= $host2; i++))
do
	echo ping $net.$i ..
	ping -c1 $net.$i > /dev/null
	success=$?
	if [ $success -eq 0 ]
	then
		ip_arr+=($net.$i)
	fi
	
done

#Scan TCP ports for successful IP addresses
echo "scanning..."
for sHOST in ${ip_arr[@]}
do
	for k in {1..30}
	do
		PORT=$k
		(echo >/dev/tcp/$sHOST/$PORT) >& /dev/null
		scan=$?
		if [ $scan -eq 0 ]
		then
			echo "port $PORT on $sHOST is open"
			echo "port $PORT on $sHOST is open" >> scan_report
		fi
	done
done
#echo "The following Addresses Responded: ${ip_arr[@]}"


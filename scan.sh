#!/bin/bash


ip_begin=$1	#beginning of IP range
ip_end=$2	#end of IP range
mask=$3		#network mask
p_range=$4	#port range 
ip_arr=()	#array to hold IP addresses

#IPv4 Validations: Parse regex for IPv4 format, verify each octets below 256
validate_ip() {
	if expr "$1" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' > /dev/null
	then
        	for i in {1..4}
        	do
                	if [ $(echo "$1" | cut -d . -f$i) -gt 255 ]
                	then 
                        	echo "ERROR: INVALID IPV4 ADDRESS: $1 ONE OR MORE OCTETS EXCEEDS 255 BITS" 
                        	exit 1
                	fi      
        	done
        
	else
        	echo "ERROR: INVALID IPV4 ADDRESS: $1"
        	exit 1
 	fi
}

#Subnet Mask Validation: validate integer between 8 and 30 is entered
validate_mask() {
	if [[ $1 =~ ^[0-9]+$ ]]
	then
        	if [[ $1 -lt 8 || $1 -gt 30 ]]
         	then
                	echo "ERROR: NETMASK MUST BE BETWEEN 8 AND 30"
                 	exit 1
         	fi
 	else
        	echo "ERROR: NETMASK MUST BE AN INTEGER BETWEEN 8 AND 30"
        	exit 1
	fi
}

#IP Class Verification: verify subnet class, divide arguments into host and network bits
ip_class() {
        if [[ $3 -le 15 ]]
        then
                #class A
                host1=`echo $1 | cut -d . -f 2-4`
                host2=`echo $2 | cut -d . -f 2-4`
                net=`echo $1 | cut -d . -f 1`
                #echo "Host Bits Are: $host"
                #echo "Network Bits Are: $net"


        elif [[ $3 -ge 16 && $3 -lt 24 ]]
        then
                #class B
                host1=`echo $1 | cut -d . -f 3-4`
                host2=`echo $2 | cut -d . -f 3-4`
                net=`echo $1 | cut -d . -f 1-2`
                #echo "Host Bits Are: $host"
                #echo "Network Bits Are: $net"
        else
                #class C
                host1=`echo $1 | cut -d . -f 4`
                host2=`echo $2 | cut -d . -f 4`
                net=`echo $1 | cut -d . -f 1-3`
                #echo "Host Bits Are: $host"
                #echo "Network Bits Are: $net"
        fi
}

validate_port() {
        if [[ $1 =~ [0-9]+\-[0-9]+ ]]
        then
                r_begin=`echo $1 | cut -d "-" -f 1`
                r_end=`echo $1 | cut -d "-" -f 2`
        else
                echo "INVALID PORT RANGE"
                echo "FORMAT MUST FOLLOW EXAMPLE: 80-200"
                exit 1
        fi
}

validate_ip $ip_begin
validate_ip $ip_end
validate_mask $mask
validate_port $p_range
ip_class $ip_begin $ip_end $mask

#Test layer 3 connection
echo "Pre-vandalism in progress: Please wait while we peek through your window :)"
for((i=$host1; i<= $host2; i++))
do
	#echo ping $net.$i ..
	ping -c1 $net.$i > /dev/null
	success=$?
	if [ $success -eq 0 ]
	then
		ip_arr+=($net.$i)
	fi
	
done
printf '%s\n' ${ip_arr[@]} > ip_map.txt

#Scan TCP ports for successful IP addresses
for sHOST in ${ip_arr[@]}
do
	for  ((k=$r_begin; k<=$r_end; k++))
	do
		PORT=$k
		(echo >/dev/tcp/$sHOST/$PORT) >& /dev/null 
		scan=$?
		if [ $scan -eq 0 ]
		then
			echo "port $PORT on $sHOST is open"
			echo "port $PORT on $sHOST is open" > scan_report
		fi
	done
done

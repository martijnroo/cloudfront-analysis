#!/bin/bash

function convert_url {
	url=$1

	case $url in
		"d39wppo36gwqpx") echo "saopaulo" && return;;
		"d3796nkzln59xv") echo "usstandard" && return;;
		"d1xvcg6dfvgaki") echo "singapore" && return;;
		"d1dx94olpiqj0t") echo "oregon" && return;;
		"d1xzxs93r3iphc") echo "ireland" && return;;
		"dm53kc3eax57k") echo "frankfurt" && return;;
		"d1n0gskdvzj94j") echo "california" && return;;
		"d3m1c4hwkgedal") echo "tokyo" && return;;
		"d2pcb72msibvx3") echo "sydney" && return;;
		*) echo "";;
	esac
}

echo "measuring location,id,datetime,S3 location,IP address,network latency,1kb (retrieval latency),10kb,100kb,1mb,10mb"

for site in home california ireland singapore
do
	id=0
	for dist in *.cloudfront.net
	do
		dist_name=$(convert_url $(echo $dist | cut -d'.' -f 1))
		for file in $dist/$site/ping*
		do
			datetime=$(echo $file | cut -d'/' -f 3 | cut -d'_' -f 2 | cut -d'.' -f 1-3)
			avg=$(cat $file | grep Average | awk '{print $9}' | cut -c1-2)
			if [ "$avg" == "" ]
			then
				avg=$(cat $file | grep avg | cut -d'/' -f 5)
			fi

			diffs=""
			for size in 1kb 10kb 100kb 1mb 10mb
			do
				tshark_file="$dist/$site/$size/${size}_${datetime}.txt"
				req_time=$(cat $tshark_file | grep -e "HTTP\s[0-9]*\sGET\s/\(1kb\|10kb\|100kb\|1mb\|10mb\)" | awk '{print $2}')
				res_time=$(cat $tshark_file | grep -A 10 -e "HTTP\s[0-9]*\sGET\s/\(1kb\|10kb\|100kb\|1mb\|10mb\)" | grep ACK | head -n 1 | awk '{print $2}')
				ip=$(cat $tshark_file | grep -A 10 -e "HTTP\s[0-9]*\sGET\s/\(1kb\|10kb\|100kb\|1mb\|10mb\)" | grep ACK | head -n 1 | awk '{print $3}')

				diffs+="$(echo "$res_time - $req_time" | bc),"
			done

			echo "$site,$id,$datetime,$dist_name,$ip,$avg,$diffs"
			((id++))
		done
	done
done

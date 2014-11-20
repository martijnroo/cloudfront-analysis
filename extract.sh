#!/bin/bash

function convert_url {
	url=$1

	case $url in
		"d17xdwadnyh5jz") echo "saopaulo" && return;;
		"d2j3h070v7ssnq") echo "usstandard" && return;;
		"d1mwrzpabofbyf") echo "singapore" && return;;
		"d1hrt2aivb7twc") echo "oregon" && return;;
		"d2btk8vfxgin4t") echo "ireland" && return;;
		"d34jimtkchmonz") echo "frankfurt" && return;;
		"d3o5detyrtwvn1") echo "california" && return;;
		"d1eenfr2uwy1l3") echo "tokyo" && return;;
		"dxuf2hxmfmw7z") echo "sydney" && return;;
		*) echo "n/a";;
	esac
}

echo "id,datetime,S3 location,measuring location,network latency,1kb (retrieval latency),10kb,100kb,1mb,10mb"

id=0
for dist in *.cloudfront.net
do
	dist_name=$(convert_url $(echo $dist | cut -d'.' -f 1))
	for site in $dist/*
	do
		site_name=$(echo $site | cut -d'/' -f 2)
		for file in $site/ping*
		do
			datetime=$(echo $file | cut -d'/' -f 3 | cut -d'_' -f 2 | cut -d'.' -f 1-3)
			avg=$(cat $file | grep Average | awk '{print $9}' | cut -c1-2)

			diffs=""
			for size in 1kb 10kb 100kb 1mb 10mb
			do
				tshark_file="$site/$size/${size}_${datetime}.txt"
				req_time=$(cat $tshark_file | grep -e "HTTP\s[0-9]*\sGET\s/\(1kb\|10kb\|100kb\|1mb\|10mb\)" | awk '{print $2}')
				res_time=$(cat $tshark_file | grep -A 10 -e "HTTP\s[0-9]*\sGET\s/\(1kb\|10kb\|100kb\|1mb\|10mb\)" | grep ACK | head -n 1 | awk '{print $2}')
				diffs+="$(echo "$res_time - $req_time" | bc),"
			done

			echo "$id,$datetime,$dist_name,$site_name,$avg,$diffs"
			((id++))
		done
	done
done


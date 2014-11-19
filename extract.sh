#!/bin/bash

for dist in *.cloudfront.net
do
	for site in $dist/*
	do
		for size in 1kb 10kb 100kb 1mb 10mb
		do
			for file in $site/$size/*.txt
			do
				req_time=$(cat $file | grep -e "HTTP\s[0-9]*\sGET\s/\(1kb\|10kb\|100kb\|1mb\|10mb\)" | awk '{print $2}')
				res_time=$(cat $file | grep -A 10 -e "HTTP\s[0-9]*\sGET\s/\(1kb\|10kb\|100kb\|1mb\|10mb\)" | grep ACK | head -n 1 | awk '{print $2}')
				time_=$(echo $file | cut -d'-' -f 3 | cut -c1-5)
				diff=$(echo "$res_time - $req_time" | bc)
				echo "$size $time_ $diff"
			done
		done

		for file in $site/ping*
		do
			avg=$(cat $file | grep Average | awk '{print $9}' | cut -c1-2)
			time_=$(echo $file | cut -d'-' -f 3 | cut -c1-5)
			echo "$time_ $avg"
		done
	done
done
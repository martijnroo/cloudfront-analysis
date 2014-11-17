queries=(1kb 10kb 100kb 1mb 10mb)
urls=(d17xdwadnyh5jz.cloudfront.net d2j3h070v7ssnq.cloudfront.net d1mwrzpabofbyf.cloudfront.net d1hrt2aivb7twc.cloudfront.net d2btk8vfxgin4t.cloudfront.net d34jimtkchmonz.cloudfront.net d3o5detyrtwvn1.cloudfront.net d1eenfr2uwy1l3.cloudfront.net dxuf2hxmfmw7z.cloudfront.net)
now="$(date +"%d.%m-%H.%M")"

for url in ${urls[@]}
do
    echo "Pinging"
    ping $url -n 10 >> $url\/ping\_$now.txt
    for query in ${queries[@]}
    do
        mkdir -p $url/$query
        file=$url\/$query\/$query\_$now.txt
        echo "[Measurement for $query at $(date +"%T %d.%M.%Y")] " > $file
        echo "Tshark:"$'\n' >> $file
        "C:\Program Files\Wireshark\tshark.exe" -a duration:3 >> $file & sleep 2; curl $url/$query >/dev/null
        sleep 2
    done
done

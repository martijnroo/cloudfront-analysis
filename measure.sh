queries=(1kb 10kb 100kb 1mb 10mb)
urls=(d39wppo36gwqpx.cloudfront.net d3796nkzln59xv.cloudfront.net d1xvcg6dfvgaki.cloudfront.net d1dx94olpiqj0t.cloudfront.net d1xzxs93r3iphc.cloudfront.net dm53kc3eax57k.cloudfront.net d1n0gskdvzj94j.cloudfront.net d3m1c4hwkgedal.cloudfront.net d2pcb72msibvx3.cloudfront.net)
now="$(date +"%d.%m-%H.%M")"

site=$1;

if [ -z "$site" ]
then
    echo "Usage: ./measure.sh <site>";
    exit 1;
fi

for url in ${urls[@]}
do
    echo "Pinging $url"
    mkdir -p $url/$site
    ping $url -c 10 >> $url\/$site\/ping\_$now.txt
    for query in ${queries[@]}
    do
        mkdir -p $url/$site/$query
        file=$url\/$site\/$query\/$query\_$now.txt
        echo "[Measurement for $query at $(date +"%T %d.%M.%Y")] " > $file
        echo "Tshark:"$'\n' >> $file
        tshark -a duration:3 >> $file & sleep 2; curl $url/$query >/dev/null
        sleep 2
    done
done

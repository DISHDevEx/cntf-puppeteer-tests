#!/usr/bin/env bash

# this script goes inside the youtube pupeteer container copies the updated logs from tests run, and stores them in local files. Furthermore, it then reflects the changes made locally files in s3.

YOUTUBE_PUPETEER_POD=$(kubectl -n openverso get pod --output=jsonpath={.items..metadata.name} -l puppeteer-script=youtube-search)

update_local_load_time () {
    kubectl cp -n openverso $YOUTUBE_PUPETEER_POD:load_time.txt ./youtube-pupeteer-load-time.txt 
}

update_local_picture () {
    kubectl cp -n openverso $YOUTUBE_PUPETEER_POD:youtube_invaders_video.png ./youtube-pupeteer-screenshot.png 
}

update_network_requests () {
    kubectl cp -n openverso $YOUTUBE_PUPETEER_POD:network_requests.txt ./youtube-network-requests.txt
}

udpate_s3() {
   aws s3 cp ./youtube-pupeteer-screenshot.png s3://cntf-open5gs-test-results/youtube-pupeteer-screenshot.png
   aws s3 cp ./youtube-pupeteer-load-time.txt s3://cntf-open5gs-test-results/youtube-pupeteer-load-time.txt
   aws s3 cp ./youtube-network-requests.txt s3://cntf-open5gs-test-results/youtube-network-requests.txt
}

update_local_load_time
update_local_picture
update_network_requests
udpate_s3

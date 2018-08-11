#!/bin/bash
HTTP_CODE=`curl -I -m 10 -o /dev/null -s -w %{http_code} https://domain.name`
if [ ${HTTP_CODE} -ne 200 ]
then
    echo "$(date +%Y.%m.%d-%H:%M) was down,the code is ${HTTP_CODE}." >> web_status.log
fi

#! /bin/sh
echo "Trying to verify $URL is up"
code=0
while [ $code -ne 200 ]
do
    echo "connecting..."
    code=$(curl -k -o /dev/null -Isw '%{http_code}\n' --connect-timeout 5 --max-time 5 $URL)
    if [ "$code" -eq 200 ]; then
        break;
    fi
    echo "...but received status $code; will check again shortly ..."
    sleep 10
done
echo "status check returned $code; proceeding..."
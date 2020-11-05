#! /bin/sh

echo "checking UAA status before installing metrics"
url=https://uaa.${DOMAIN_ENDPOINT}/.well-known/openid-configuration
echo "Trying to verify ${url} is up"

max_retries=30
count=0
code=0
while [ $code -ne 200 ]
do
    ((count+=1))
    if [[ $count == 1 ]]; then
        count_string="1st"
    elif [[ $count == 2 ]]; then
        count_string="2nd"
    elif [[ $count == 3 ]]; then
        count_string="3rd"
    else
        count_string="${count}th"
    fi
    
    echo "${count_string} try - connecting to UAA at ${url}..."
    
    code=$(curl -o /dev/null -Isw '%{http_code}\n' --connect-timeout 5 --max-time 5 $url)
    
    if [[ "$code" == '200' ]]; then 
        break;
    fi

    if [ $count -ge $max_retries ]; then
        echo "...but received status ${code}."
        echo "Too many retries - bailing out."
        exit 1
    fi

    echo "...but received status ${code}; will check again in 2 minutes ..."
    sleep 120
done
echo "UAA status check returned ${code}; proceeding..."

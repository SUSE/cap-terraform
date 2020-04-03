#! /bin/sh
export KUBECONFIG=./kubeconfig
APISRV="$(kubectl cluster-info| head -n 1|grep -o ' at .*$'| cut -f3 -d' '| cut -f3 -d'/'|cut -f1 -d':')"

echo "checking UAA status before installing metrics"
url=https://uaa.${METRICS_API_ENDPOINT}/.well-known/openid-configuration
echo "Trying to verify ${url} is up"
code=400
while [ $code -ne 200 ]
do
    echo "Connecting to UAA..."
    code=$(curl -k -o /dev/null -Isw '%{http_code}\n' --connect-timeout 5 --max-time 5 $url)
    if [[ "$code" == '200' ]]; then
        break;
    fi
    echo "...but received status ${code}; will check again in a minute ..."
    sleep 60
done
echo "UAA status check returned ${code}; proceeding to the helm install..."

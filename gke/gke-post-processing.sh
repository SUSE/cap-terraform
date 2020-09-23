#!/usr/bin/env bash

gcloud auth revoke

gcloud auth activate-service-account --key-file=${SA_KEY_FILE}

gcloud container clusters get-credentials  ${CLUSTER_NAME} --zone ${CLUSTER_ZONE:?required} --project ${PROJECT}

checkready() {
	while [[ $node_readiness != "$NODE_COUNT True" ]]; do
		sleep 10
		node_readiness=$(
			kubectl get nodes -o json \
      		| jq -r '.items[] | .status.conditions[] | select(.type == "Ready").status' \
      		| uniq -c | grep -o '\S.*'
  		)
	done
}

kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

checkready

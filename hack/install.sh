#!/bin/bash

set -e

serviceaccount='./artifacts/serviceaccount.yaml'
clusterrole='./artifacts/clusterrole.yaml'
clusterrolebinding='./artifacts/clusterrolebinding.yaml'
new_deployment='./artifacts/deployment.yaml'
template_deployment='./artifacts/deployment-template.yaml'

if [ -z "${AWS_REGIONS}" ]; then
    echo "AWS_REGIONS not set in environment, exiting"
    exit 1
fi
if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
    echo "AWS_ACCESS_KEY_ID not set in environment, exiting"
    exit 1
fi
if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
    echo "AWS_SECRET_ACCESS_KEY not set in environment, exiting"
    exit 1
fi

export WPA_AWS_REGIONS="${AWS_REGIONS}"
export WPA_AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
export WPA_AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"

cp -f $template_deployment $new_deployment
./hack/generate.sh ${new_deployment}

kubectl apply -f ${serviceaccount}
kubectl apply -f ${clusterrole}
kubectl apply -f ${clusterrolebinding}
kubectl apply -f ${new_deployment}
kubectl get pods -n kube-system | grep workerpodautoscaler

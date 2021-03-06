#!/bin/bash -x

set -e -u -o pipefail

TEMPLATE_ATTEMPTS=0
until http --check-status GET ${ELASTIC_URL:=elasticsearch:9200}/_template/pingfail; do
    [[ $TEMPLATE_ATTEMPTS -lt 9 ]] || {
        echo "ERROR: tried to PUT the index template"
        exit 1
    }
    http --json --verbose PUT elasticsearch:9200/_template/pingfail < ./index-template.json
    let TEMPLATE_ATTEMPTS++ || true
    sleep 1
done


while :; do
    if eval ping -W1 -c1 -${PING_IPV:=4} ${PING_TGT:=8.8.8.8} >/dev/null; then
        http \
            --check-status \
            --verbose \
            --ignore-stdin \
            POST \
            ${ELASTIC_URL}/pingfail-$(date +%Y.%m.%d)/_doc/ \
            ping:=true \
            target=${PING_TGT} \
            timestamp=$(( $(date +%s)*1000 ))
    else
        http \
            --check-status \
            --verbose \
            --ignore-stdin \
            POST \
            ${ELASTIC_URL}/pingfail-$(date +%Y.%m.%d)/_doc/ \
            ping:=false \
            target=${PING_TGT} \
            timestamp=$(( $(date +%s)*1000 ))
    fi
    sleep 1
done

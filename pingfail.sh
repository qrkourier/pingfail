#!/bin/bash

set -e -u -o pipefail

TEMPLATE_ATTEMPTS=0
until http --check-status GET elasticsearch:9200/_template/pingfail; do
    [[ $TEMPLATE_ATTEMPTS -lt 9 ]] || {
        echo "ERROR: tried to PUT the index template"
        exit 1
    }
    http --check-status --json --verbose PUT elasticsearch:9200/_template/pingfail < /index-template.json
    let TEMPLATE_ATTEMPTS++
    sleep 1
done


while :; do
    ping -W1 -c1 ${PING_STRING:- -4 8.8.8.8} >/dev/null || {
        http --check-status --json --verbose POST elasticsearch:9200/pingfail-$(date +%Y.%m.%d)/_doc/ ping:=false timestamp=$(( $(date +%s)*1000 ))
    };
    sleep 1;
done

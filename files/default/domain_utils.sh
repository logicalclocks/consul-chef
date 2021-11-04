#!/usr/bin/env bash

_is_service_ready () {
    SERVICE=$1
    DOMAIN_NAME=$2
    MAX_ATTEMPTS=10
    if [ $# -eq 3 ]
    then
	MAX_ATTEMPTS=$3
    fi
    echo "Checking readiness of $SERVICE <$DOMAIN_NAME>"
    attempt=0
    while ! host $DOMAIN_NAME
    do
        ((attempt+=1))
        if [ $attempt -gt $MAX_ATTEMPTS ]
        then
            ! break
        fi
        if systemctl list-units --full -all | grep -Fq $SERVICE
        then
            if systemctl is-active --quiet $SERVICE
            then
                sleep 5
            else
                ! break
            fi
        else
            sleep 5
        fi;
    done
}
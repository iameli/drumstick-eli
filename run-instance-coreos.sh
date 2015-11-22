#!/bin/bash
USERDATA=`cat provision-host-coreos.sh | base64`
JSON=`cat spotinstance-coreos.json | jq ".*{\"LaunchSpecification\": {\"UserData\": \"$USERDATA\"}}"`
aws ec2 request-spot-instances --cli-input-json "$JSON" $*

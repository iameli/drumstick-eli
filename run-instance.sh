#!/bin/bash
USERDATA=`cat provision-host.sh | base64`
JSON=`cat spotinstance.json | jq ".*{\"LaunchSpecification\": {\"UserData\": \"$USERDATA\"}}"`
aws ec2 request-spot-instances --cli-input-json "$JSON" $*

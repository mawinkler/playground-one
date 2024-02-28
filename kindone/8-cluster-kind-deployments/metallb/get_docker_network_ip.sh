#!/bin/bash

# docker network inspect kind | jq '.[0].IPAM.Config[1]'
docker network inspect kind | jq '.[0].IPAM.Config[] | select(.Gateway) | .'

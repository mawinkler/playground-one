#!/bin/bash

docker network inspect kind | jq '.[0].IPAM.Config[0]'

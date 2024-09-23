#!/bin/bash

cd $HOME/download

archive=TMSensorAgent_Linux.tar

if [ -f "${archive}" ]; then
    tar xf ${archive}
    sudo ./tmxbc install
fi

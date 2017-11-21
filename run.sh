#!/bin/bash
ip=`ip a | grep global | grep eth0 | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])'`

export NODE_NAME=gateway@$ip

/opt/sites/fsa-reactive-gateway/bin/gateway foreground
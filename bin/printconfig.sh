#!/bin/bash

while read line
do
    grep -q GET "$line" | sed -e 's#GET /\([a-z]\).ovpn HTTP.*#\1#g' | grep -q . && \
        cat client.$(grep -q GET "$line" | sed -e 's#GET /\([a-z]\).ovpn HTTP.*#\1#g').combined.ovpn
done

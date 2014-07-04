#!/bin/bash

pgrep clamd &>/dev/null; if [[ $? == 1 ]]; then echo "clamd is down"; exit 2; else echo "clamd is up"; fi

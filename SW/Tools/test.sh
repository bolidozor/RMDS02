#!/usr/bin/env bash

ssh  -o StrictHostKeyChecking=no -o BatchMode=yes meteor@neptun.avc-cvut.cz "exit"

[[ "$?" -eq 0 ]] && exit 0 || exit 1
#!/usr/bin/env bash

ssh  -o StrictHostKeyChecking=no -o BatchMode=yes $1@space.astro.cz "exit"

[[ "$?" -eq 0 ]] && exit 0 || exit 1
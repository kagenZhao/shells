#!/usr/bin/env bash

source ./tools.sh

OPTARG="./app.sh"
echo ${OPTARG/\.\//$HOME\/}
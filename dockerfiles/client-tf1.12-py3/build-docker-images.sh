#!/bin/bash

set -e

cd `dirname $0`

docker build -t orion-client:tf1.12-py3 .

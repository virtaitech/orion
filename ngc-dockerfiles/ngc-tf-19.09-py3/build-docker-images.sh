#!/bin/bash

set -e

cd `dirname $0`

docker build -t 10.10.1.20:5000/test:ngc-tf-19.09-py3 .

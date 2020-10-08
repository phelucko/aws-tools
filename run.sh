#!/bin/sh

if [ -n $DOCKER_HOST_GID ]; then
  groupmod -g $DOCKER_HOST_GID docker
fi

if [ $# -eq 0 ]; then
  echo "Usage: run.sh [aws|sam] <arguments>"
  exit 1;
fi

dir=$(pwd)
cmd="su - aws -c 'cd $dir && $@'"

eval $cmd

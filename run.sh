#!/bin/sh

if [ ! -z $DOCKER_HOST_GID ]; then
  groupmod -g $DOCKER_HOST_GID docker
fi

if [ "$1" = "aws" ]; then
  mode="aws"
  shift
elif [ "$1" = "sam" ]; then
  mode="sam"
  shift
fi

if [ -z "$mode" ] || [ $# -eq 0 ]; then
  cat << EOF
This script supports both aws and sam.

aws: run.sh aws [arguments]

sam: run.sh sam --host-working-dir directory [arguments]"
EOF
  exit 1;
fi

params=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --host-working-dir)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        working_dir=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    *) # preserve positional arguments
      params="$params $1"
      shift
      ;;
  esac
done

dir=$(pwd)
if [ "$mode" = "aws" ]; then
  cmd="su - aws -c 'cd $dir && aws $params'"
else
  case $working_dir in
    "$dir"*)
      cmd="su - aws -c 'cd $working_dir && sam $params'"
      ;;
    *)
      cmd="su - aws -c 'cd $dir && sam $params'"
      ;;
  esac
fi

eval $cmd

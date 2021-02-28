#!/bin/env bash
if [[ ! -z ${TEMPLATE_DEBUG}  ]];
then
  set -x
fi

function getNewTemplate() {
  grep -xq "templates/$1" $cache/.git/info/sparse-checkout || echo templates/$1 >> $cache/.git/info/sparse-checkout
  git -C $cache pull --depth=1 origin master
}

function checkTemplate() {
  if [[ -e "$cache/templates/$1" ]]; then
    return 0
  else 
    return 1
  fi
}

function createCache() {
  mkdir $cache
  git init $cache
  git -C $cache config core.sparseCheckout true
  git -C $cache remote add origin $1
} 

function usage() {
  echo "./$(basename $0): [-h/--help] [-v/--version] <name> <template>" 1>&2
}

function updateTemplates() {
  git -C $cache pull origin master
}

repo=https://github.com/saucecode/bp
cache=~/.cache/template
name=unset
template=unset

if [[ ${#} -eq 0 ]]; then
   usage
   exit 1
fi

opts=$(getopt -a -n template -o hv -l help,version -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

eval set -- "$opts"
while :
do
  case "$1" in 
    -h | --help) usage && exit 0; shift;;
    -v | --version) echo "template v1.0" && exit 0; shift;;
    --) shift; break;;
  esac
done

name=${@:1:1}
template=${@:2:1}


if [[ ! -d $cache ]]; then
  createCache "$repo" 
fi

checkTemplate "$template" || getNewTemplate "$template" && updateTemplates

mkdir "$name"
cp "$cache/templates/$template" "$name/"
git init "$name"
git -C "$name" add -A
git -C "$name" commit -m "First commit"

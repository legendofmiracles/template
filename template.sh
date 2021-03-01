#!/bin/env bash
if [[ ! -z ${TEMPLATE_DEBUG}  ]];
then
  set -x
fi

function getNewTemplate() {
  grep -xq "templates/$1" $cache/.git/info/sparse-checkout 2> /dev/null || echo templates/$1 >> $cache/.git/info/sparse-checkout
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
  echo "./$(basename $0): [-h/--help] [-v/--version] [-n/--name] <template> [directory]" 1>&2
  echo "If no directory specified then it's the current dir.\nAnd each template has a default name set, if you don't specify one."
}

function updateTemplates() {
  git -C $cache pull --depth=1 origin master
}

repo=https://github.com/legendofmiracles/template
cache=~/.cache/template
name=unset

# checks that we have any args at all
if [[ ${#} -eq 0 ]]; then
   usage
   exit 1
fi

opts=$(getopt -a -n template -o hvn: -l help,version,name: -- "$@")

# checks that parsing went ok
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
  exit
fi

eval set -- "$opts"
while :
do
  case "$1" in 
    -h | --help) usage && exit 0; shift;;
    -v | --version) echo "template v1.0" && exit 0; shift;;
    -n | --name) name=$2; shift 2;;
    --) shift; break;;
  esac
done

# checks that we have the required args
if [[ ! $# -ge 1 ]]; then
  usage
  exit
fi

#name=${@:1:1}
template=${@:1:1}
directory=${@:2:1}
if [[ ! $directory  ]]; then
  directory=.
fi

if [[ ! -d $cache ]]; then
  createCache "$repo" 
fi

checkTemplate "$template" || getNewTemplate "$template" && updateTemplates

mkdir "$directory" 2> /dev/null
cp -r "$cache/templates/$template/." "$directory/"
if [[ name == unset ]]; then
  name=$(yq -r .[0].default[].NAME template.yml)
  if [[ $? -eq 0 && ! -z $name ]]; then
    find . -type f -not -path '*/\.*' -exec sed -i 's/{{NAME}}/'$name'/g' {} +
  fi
fi
git init "$directory"
git -C "$directory" add -A
git -C "$directory" commit -m "First commit"

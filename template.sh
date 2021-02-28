#!/bin/env bash
set -x

function getNewTemplate() {
  echo $1 >> $cache/.git/info/sparse-checkout
  git -C $cache pull origin master
}

function checkTemplate() {
  if [[ -d "$cache/$1" ]]; then
    return 0
  else 
    return 1
  fi
}

function createCache() {
  mkdir $cache
  git init $cache
  git config core.sparseCheckout true
  git -C $cache remote add origin $1
}

repo=https://github.com/saucecode/bp
cache=~/.cache/template

name=$1
template=$2

if [[ ! -d $cache ]]; then
  createCache "$repo" 
fi

checkTemplate "$template" || getNewTemplate "$template"

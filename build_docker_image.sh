#!/usr/bin/env bash
set -e # exit on first error
set -u # exit on using unset variable

githash=$(git rev-parse --short HEAD)

# build
docker build --progress plain -f Dockerfile -t majorsilence/mac_wine_bundler:$githash --rm=true -m 4GB .


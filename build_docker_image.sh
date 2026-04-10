#!/usr/bin/env bash
set -e # exit on first error
set -u # exit on using unset variable

githash=$(git rev-parse --short HEAD)

# build
docker buildx build --progress plain --provenance=true --sbom=true --load -f Dockerfile -t majorsilence/mac_wine_bundler:$githash -m 4GB .


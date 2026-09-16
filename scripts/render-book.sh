#!/usr/bin/env bash

set -euo pipefail

julia --threads auto --project=. -e '
  using Pkg
  Pkg.instantiate()
  Pkg.build("RCall")
'

quarto render "$@"

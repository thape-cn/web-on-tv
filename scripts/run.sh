#!/usr/bin/env bash
set -euo pipefail
PROJECT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
RUNTIME=${DRAGONRUBY_HOME:-/workspace/shared/dragonruby/current}
if [[ ! -x "$RUNTIME/dragonruby" ]]; then
  echo 'Set DRAGONRUBY_HOME to your licensed DragonRuby installation.' >&2
  exit 1
fi
cd "$RUNTIME"
exec ./dragonruby "$PROJECT"

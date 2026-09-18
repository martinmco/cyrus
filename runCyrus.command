#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
exec ./runCyrus.sh start

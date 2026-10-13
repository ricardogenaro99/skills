#!/usr/bin/env bash
set -euo pipefail

# Genaryth Autonomous Squad Framework (GASF v2.0)
# Multi-Agent Benchmark Runner Wrapper

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
node --experimental-strip-types "${SCRIPT_DIR}/runner.ts" "$@"

#!/usr/bin/env bash
set -euo pipefail
echo "🚨 Scanning \${PIPE_DIR} with Checkov..."
checkov -d "\${PIPE_DIR}"

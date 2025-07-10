#!/usr/bin/env bash
set -euo pipefail
echo "🔍 Running tf-lint against \${PIPE_DIR}..."
cd "\${PIPE_DIR}"
tflint --format standard

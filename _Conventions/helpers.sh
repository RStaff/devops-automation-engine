#!/usr/bin/env bash
# Minimal stubbed helpers — no git calls, just echo

init_pipeline() {
  echo "🚀 init_pipeline called for '$1' in '$2'"
}

run_tool_step() {
  TOOL="$1"
  PIPE_DIR="$2"
  echo "🔧 running tool '$TOOL' in pipeline '$PIPE_DIR'"
}

notify_status() {
  STATUS="$1"
  PIPE_DIR="$2"
  echo "📣 pipeline '$PIPE_DIR' finished with status '$STATUS'"
}

    tflint)
      echo "🔍 tflint on $PIPELINE_DIR"
      (cd "$PIPELINE_DIR" && tflint)
      ;;
    checkov)
      echo "🔐 checkov on $PIPELINE_DIR"
      checkov -d "$PIPELINE_DIR"
      ;;

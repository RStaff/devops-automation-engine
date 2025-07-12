#!/bin/bash

echo "🔎 Validating CI/CD pipeline workflow files and scripts..."

FAILED=0

# 1. List all CI workflow YAML files
echo ""
echo "==> Checking workflow YAML files in .github/workflows:"
for yml in .github/workflows/ci-*.yml; do
  echo "  - $yml"
done

# 2. Check triggers and paths for each workflow
echo ""
echo "==> Checking triggers and paths in workflow files:"
for yml in .github/workflows/ci-*.yml; do
  PIPELINE=$(basename "$yml" | sed 's/^ci-\(.*\)\.yml$/\1/')
  if grep -q 'on:' "$yml" && grep -q "push:" "$yml" && grep -q "paths:" "$yml"; then
    echo "✅ [$yml] has triggers and paths"
  else
    echo "❌ [$yml] MISSING triggers or paths!"
    FAILED=1
  fi

  # 3. Check that script paths match directory
  DIR_NAME="${PIPELINE//-/_}"   # replace dashes with underscores for folder names
  for step in extract.sh transform.sh load.sh; do
    if ! grep -q "$DIR_NAME/$step" "$yml"; then
      echo "❌ [$yml] does not reference $DIR_NAME/$step"
      FAILED=1
    fi
  done
done

# 4. Check each pipeline directory for scripts
echo ""
echo "==> Checking each pipeline directory for required scripts:"
for dir in *_pipeline; do
  missing=""
  for step in extract.sh transform.sh load.sh; do
    if [[ ! -x "$dir/$step" ]]; then
      if [[ ! -f "$dir/$step" ]]; then
        echo "❌ [$dir] Missing $step"
        FAILED=1
        missing="1"
      elif [[ ! -x "$dir/$step" ]]; then
        echo "⚠️  [$dir/$step] exists but is not executable. Run: chmod +x $dir/$step"
        missing="1"
      fi
    fi
  done
  [[ -z "$missing" ]] && echo "✅ [$dir] All scripts present and executable"
done

echo ""
if [[ $FAILED -eq 0 ]]; then
  echo "🎉 All checks passed! Your pipelines are production-ready."
else
  echo "❌ Some issues were found. Please fix the errors above."
fi


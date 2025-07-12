#!/bin/bash
set -e

for file in .github/workflows/ci-*.yml; do
  # Skip pipeline-template or _pipeline files
  [[ "$file" == *_pipeline.yml ]] && continue

  # Get the base name
  basename=$(basename "$file" .yml | sed 's/^ci-//')
  pipedir="${basename//-/_}_pipeline"
  displayname=$(echo "$basename" | sed -E 's/(^|-)([a-z])/\U\2/g; s/_/ /g')

  # Update the name: line (friendly pipeline name)
  sed -i '' -E "s/^name:.*/name: CI – $displayname Pipeline/" "$file"

  # Update any on: paths: line to correct pipeline dir
  # Handles both YAML list and array
  sed -i '' -E "s|(paths:[^']*')[^']+'|\1'$pipedir/**'|" "$file"
  sed -i '' -E "s|(paths:[^-\[]*- *)['\"][^'\"]+['\"]|\1'$pipedir/**'|" "$file"

  # Update bash script steps
  sed -i '' -E "s|bash [^/]+/extract.sh|bash $pipedir/extract.sh|g" "$file"
  sed -i '' -E "s|bash [^/]+/transform.sh|bash $pipedir/transform.sh|g" "$file"
  sed -i '' -E "s|bash [^/]+/load.sh|bash $pipedir/load.sh|g" "$file"

  echo "✅ Updated $file"
done

echo "🚀 All CI YAMLs standardized."
#!/bin/bash
set -e

for file in .github/workflows/ci-*.yml; do
  # Only operate on friendly names (skip anything with "_pipeline")
  [[ "$file" == *_pipeline.yml ]] && continue

  # Get the base name (e.g., ad-analytics from ci-ad-analytics.yml)
  basename=$(basename "$file" .yml | sed 's/^ci-//')
  # Convert hyphens to underscores for paths and commands
  pipedir="${basename//-/_}_pipeline"

  # Capitalize and format the friendly name (hacky but works)
  displayname=$(echo "$basename" | sed -E 's/(^|-)([a-z])/\U\2/g; s/_/ /g')

  # Update name: line (optional, but nice)
  sed -i '' -E "s/^name:.*/name: CI – $displayname Pipeline/" "$file"

  # Update path in on: block (for pipeline triggers)
  sed -i '' -E "s|(paths: *\[?) *[\"']?.*?ad_analytics_pipeline.*[\"']?|\1 '$pipedir/**'|" "$file"
  sed -i '' -E "s|(paths: *- *)[\"']?.*?ad_analytics_pipeline.*[\"']?|\1'$pipedir/**'|" "$file"

  # Update bash script paths in run steps
  sed -i '' -E "s|bash [a-zA-Z0-9_\-]*/extract.sh|bash $pipedir/extract.sh|g" "$file"
  sed -i '' -E "s|bash [a-zA-Z0-9_\-]*/transform.sh|bash $pipedir/transform.sh|g" "$file"
  sed -i '' -E "s|bash [a-zA-Z0-9_\-]*/load.sh|bash $pipedir/load.sh|g" "$file"

  echo "✅ Updated $file"
done

echo "🚀 All CI YAMLs standardized."


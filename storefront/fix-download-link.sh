#!/usr/bin/env bash
set -e

# 1) New download URL
NEW_URL="https://your-bucket.s3.amazonaws.com/agent_v2.zip"

# 2) Replace any .zip references in code/templates
grep -RIl "https://your-bucket.s3.amazonaws.com/agent_v2.zip" . | while read FILE; do
  echo "Patching $FILE"
  sed -i '' "s|https://your-bucket.s3.amazonaws.com/agent_v2.zip|${NEW_URL}|g" "$FILE"
done

# 3) (Optional) Remove local ZIP if you no longer need it
if [ -f public/https://your-bucket.s3.amazonaws.com/agent_v2.zip ]; then
  git rm public/https://your-bucket.s3.amazonaws.com/agent_v2.zip
fi

# 4) Commit & deploy
git add .
git commit -m "chore: point downloads at S3-hosted ZIP"
git push origin main
npx vercel --prod --yes

echo "✅ Download links updated to ${NEW_URL}"

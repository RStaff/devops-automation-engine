#!/usr/bin/env bash
set -e

# Your new hosted ZIP URL:
NEW_URL="https://your-bucket.s3.amazonaws.com/agent_v2.zip"

# 1) Replace in your activation Lambda (if any)
ACT_FILE="lambda/agent_activation.js"
if [ -f "$ACT_FILE" ]; then
  sed -i '' "s|agent_v1.zip|$NEW_URL|g" "$ACT_FILE"
fi

# 2) Replace in any success page or email template
for FILE in pages/success.js pages/index.js; do
  if grep -q "agent.zip" "$FILE"; then
    sed -i '' "s|agent.zip|$NEW_URL|g" "$FILE"
  fi
done

# 3) Commit & deploy
git add .
git commit -m "chore: point downloads at hosted ZIP instead of local agent.zip"
git push origin main
npx vercel --prod --yes

echo "✅ All references updated to $NEW_URL and deployed!"

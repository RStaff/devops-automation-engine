#!/usr/bin/env bash
set -e

SCHEMA="prisma/schema.prisma"

# 1) Remove any line containing '${STAMP}'
grep -q '\${STAMP}' "$SCHEMA" && \
  sed -i '' '/\${STAMP}/d' "$SCHEMA" && \
  echo "✅ Removed placeholder from $SCHEMA"

# 2) Re-generate your migration
npx prisma migrate dev --name init --skip-seed

# 3) Launch Studio so you can verify
npx prisma studio

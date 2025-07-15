#!/usr/bin/env bash
set -e

# 1) Install Prisma and client
npm install prisma @prisma/client --save-dev

# 2) Initialize Prisma (SQLite datasource)
npx prisma init --datasource-provider sqlite

# 3) Define an Order model
STAMP='// 💾 Order model added by setup-db.sh'
PRISMA_FILE=prisma/schema.prisma

if ! grep -q "model Order" "$PRISMA_FILE"; then
  # insert Order model at end of schema.prisma
  cat >> "$PRISMA_FILE" << 'SCHEMA'

${STAMP}
model Order {
  id                 Int     @id @default(autoincrement())
  stripeSessionId    String  @unique
  amountTotal        Int
  customerEmail      String?
  createdAt          DateTime @default(now())
}
SCHEMA
fi

# 4) Run migration
npx prisma migrate dev --name add_order_model --preview-feature

# 5) Generate a Prisma client
npx prisma generate

# 6) Patch your webhook handler to save orders
API_FILE=pages/api/webhooks.js

if grep -q "const stripe =" "$API_FILE"; then
  # insert Prisma import at top
  sed -i '' '1s#^#import { PrismaClient } from "@prisma/client"\nconst prisma = new PrismaClient()\n#' "$API_FILE"
fi

# after you verify event, write to DB
PATCH_MARKER="// TODO: fulfill order"
if ! grep -q "await prisma.order.create" "$API_FILE"; then
  sed -i '' "/${PATCH_MARKER}/a\\
    await prisma.order.create({ data: { \\
      stripeSessionId: session.id, \\
      amountTotal: session.amount_total, \\
      customerEmail: session.customer_email \\
    } })\\
" "$API_FILE"
fi

echo "✅ Database setup complete. Run 'npm run dev' and trigger a checkout to test."

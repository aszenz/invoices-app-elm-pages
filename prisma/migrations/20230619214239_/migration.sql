/*
  Warnings:

  - You are about to drop the column `content` on the `InvoiceItems` table. All the data in the column will be lost.

*/
-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_InvoiceItems" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "product" TEXT NOT NULL,
    "quantity" REAL NOT NULL,
    "price" REAL NOT NULL,
    "invoiceId" INTEGER NOT NULL,
    CONSTRAINT "InvoiceItems_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "Invoice" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_InvoiceItems" ("id", "invoiceId", "price", "product", "quantity") SELECT "id", "invoiceId", "price", "product", "quantity" FROM "InvoiceItems";
DROP TABLE "InvoiceItems";
ALTER TABLE "new_InvoiceItems" RENAME TO "InvoiceItems";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;

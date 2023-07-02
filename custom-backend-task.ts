import { PrismaClient } from "@prisma/client";
import getDB from "./src/Data/DB";

export { getInvoices, getInvoice };

const prisma = new PrismaClient();
console.log("prismac");

async function getInvoices(search: any) {
  return await getDB(prisma).getRepository("invoiceRepository").getInvoices({});
}

async function getInvoice({ invoiceNumber }: { invoiceNumber: string }) {
  console.log("getinv");
  return await getDB(prisma)
    .getRepository("invoiceRepository")
    .getInvoice(invoiceNumber);
}

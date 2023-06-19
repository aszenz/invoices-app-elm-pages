import getDB from "./src/Data/DB";

export { getInvoices, getInvoice };

async function getInvoices() {
  return await getDB().getRepository("invoiceRepository").getInvoices();
}

async function getInvoice({ invoiceNumber }: { invoiceNumber: string }) {
  const inv = await getDB()
    .getRepository("invoiceRepository")
    .getInvoice(invoiceNumber);
  console.log("i", inv);
  return inv;
}

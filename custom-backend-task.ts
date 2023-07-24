import { Prisma, PrismaClient } from "@prisma/client";

export {
  getInvoices,
  getInvoice,
  updateInvoice,
  invoiceNoExists,
  createInvoice,
  deleteInvoice,
};

const prisma = new PrismaClient();

async function getInvoices(search: Record<string, string>) {
  console.log("search input", search);
  const invoices = await prisma.invoice.findMany({
    include: { items: true },
    where: {
      company: { contains: search.company },
      number: { contains: search.number },
      // date: { equals: search.date },
    },
  });
  return invoices;
}

async function getInvoice({ id }: { id: string }) {
  const invoice = await prisma.invoice.findUnique({
    where: { id: Number(id) },
    include: { items: true },
  });
  return invoice;
}

async function updateInvoice({
  id,
  newData,
}: {
  id: string;
  newData: {
    number: string;
    company: string;
    date: string;
    items?: Prisma.InvoiceItemsUpdateManyWithoutInvoiceNestedInput;
  };
}) {
  const invoice = await prisma.invoice.update({
    where: {
      id: Number(id),
    },
    data: {
      number: newData.number,
      company: newData.company + " ss",
      date: new Date(newData.date),
      items: newData.items,
    },
    include: {
      items: true,
    },
  });
  return invoice;
}

async function createInvoice(data: {
  number: string;
  company: string;
  date: string;
  items: Prisma.InvoiceItemsCreateNestedManyWithoutInvoiceInput;
}) {
  const invoice = await prisma.invoice.create({
    data: {
      number: data.number,
      company: data.company,
      date: new Date(data.date),
      items: data.items,
    },
    include: {
      items: true,
    },
  });
  return invoice;
}

async function deleteInvoice({ id }: { id: string }) {
  console.log("invoice", id);
  const _ = await prisma.invoice.delete({
    where: {
      id: Number(id),
    },
  });
}

async function invoiceNoExists({ invoiceNumber }: { invoiceNumber: string }) {
  const invoice = await prisma.invoice.findUnique({
    where: {
      number: invoiceNumber,
    },
  });
  return null !== invoice;
}

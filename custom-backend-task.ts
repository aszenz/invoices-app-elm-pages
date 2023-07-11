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

async function getInvoices(search: any) {
  const invoices = await prisma.invoice.findMany({
    include: { items: true },
  });
  return invoices;
}

async function getInvoice({ invoiceNumber }: { invoiceNumber: string }) {
  const invoice = await prisma.invoice.findUnique({
    where: { number: invoiceNumber },
    include: { items: true },
  });
  return invoice;
}

async function updateInvoice({
  invoiceNumber,
  newData,
}: {
  invoiceNumber: string;
  newData: {
    company: string;
    date: string;
    items?: Prisma.InvoiceItemsUpdateManyWithoutInvoiceNestedInput;
  };
}) {
  const invoice = await prisma.invoice.update({
    where: {
      number: invoiceNumber,
    },
    data: {
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

async function deleteInvoice({ invoiceNumber }: { invoiceNumber: string }) {
  const _ = await prisma.invoice.delete({
    where: {
      number: invoiceNumber,
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

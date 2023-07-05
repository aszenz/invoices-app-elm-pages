import { PrismaClient } from "@prisma/client";

export {
  getInvoices,
  getInvoice,
  updateInvoice,
  invoiceNoExists,
  createInvoice,
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
  newData: { company: string; date: string };
}) {
  const invoice = await prisma.invoice.update({
    where: {
      number: invoiceNumber,
    },
    data: {
      company: newData.company + " ss",
      date: new Date(newData.date),
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
}) {
  const invoice = await prisma.invoice.create({
    data: {
      number: data.number,
      company: data.company,
      date: data.date,
    },
    include: {
      items: true,
    },
  });
  return invoice;
}

async function invoiceNoExists({ invoiceNumber }: { invoiceNumber: string }) {
  const invoice = await prisma.invoice.findUnique({
    where: {
      number: invoiceNumber,
    },
  });
  return null !== invoice;
}

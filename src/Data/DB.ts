import { PrismaClient } from "@prisma/client";

export default getDB;

type Repositories = {
  invoiceRepository: InvoiceRepository;
};

class Database {
  #prisma: PrismaClient;
  constructor(prisma: PrismaClient) {
    this.#prisma = prisma;
  }
  getRepository<T extends keyof Repositories>(repository: T): Repositories[T] {
    switch (repository) {
      case "invoiceRepository": {
        return new InvoiceRepository(prisma);
      }
      default:
        throw new Error("Never");
    }
  }
}

class InvoiceRepository {
  #prisma: PrismaClient;
  constructor(prisma: PrismaClient) {
    this.#prisma = prisma;
  }
  async getInvoices() {
    const invoices = await prisma.invoice.findMany({
      include: { items: true },
    });
    return invoices;
  }
  async getInvoice(invoiceNumber: string) {
    const invoice = await prisma.invoice.findUnique({
      where: { number: invoiceNumber },
      include: { items: true },
    });
    return invoice;
  }
}

const prisma = new PrismaClient();

function getDB() {
  return new Database(prisma);
}

// getDB()
//   .then(async () => {
//     await prisma.$disconnect();
//   })
//   .catch(async (e) => {
//     console.error(e);
//     await prisma.$disconnect();
//     throw e;
//   });

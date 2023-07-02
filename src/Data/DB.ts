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
        return new InvoiceRepository(this.#prisma);
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
  async getInvoices(filter: Record<string, string>) {
    const invoices = await this.#prisma.invoice.findMany({
      include: { items: true },
    });
    return invoices;
  }
  async getInvoice(invoiceNumber: string) {
    const invoice = await this.#prisma.invoice.findUnique({
      where: { number: invoiceNumber },
      include: { items: true },
    });
    return invoice;
  }
}

function getDB(prisma: PrismaClient) {
  return new Database(prisma);
}

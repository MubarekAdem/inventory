import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateInventoryItemDto } from './dto/create-inventory-item.dto';
import { UpdateInventoryItemDto } from './dto/update-inventory-item.dto';
import { InventoryStatus } from '@prisma/client';

@Injectable()
export class InventoryService {
  constructor(private prisma: PrismaService) {}

  async createItem(
    createInventoryItemDto: CreateInventoryItemDto,
    createdById: string,
  ) {
    // Determine status based on quantity
    let status = createInventoryItemDto.status;
    if (!status) {
      if (createInventoryItemDto.quantity === 0) {
        status = InventoryStatus.OUT_OF_STOCK;
      } else if (
        createInventoryItemDto.quantity <= createInventoryItemDto.minQuantity
      ) {
        status = InventoryStatus.LOW_STOCK;
      } else {
        status = InventoryStatus.IN_STOCK;
      }
    }

    const item = await this.prisma.inventoryItem.create({
      data: {
        ...createInventoryItemDto,
        status,
        createdById,
      },
      include: {
        createdBy: {
          select: {
            id: true,
            username: true,
            role: true,
          },
        },
      },
    });

    return item;
  }

  async findAll(
    page = 1,
    limit = 10,
    search?: string,
    category?: string,
    status?: InventoryStatus,
  ) {
    const skip = (page - 1) * limit;

    const where: any = {};

    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { sku: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    if (category) {
      where.category = { contains: category, mode: 'insensitive' };
    }

    if (status) {
      where.status = status;
    }

    const [items, total] = await Promise.all([
      this.prisma.inventoryItem.findMany({
        where,
        skip,
        take: limit,
        include: {
          createdBy: {
            select: {
              id: true,
              username: true,
              role: true,
            },
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
      }),
      this.prisma.inventoryItem.count({ where }),
    ]);

    return {
      items,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: string) {
    const item = await this.prisma.inventoryItem.findUnique({
      where: { id },
      include: {
        createdBy: {
          select: {
            id: true,
            username: true,
            role: true,
          },
        },
      },
    });

    if (!item) {
      throw new NotFoundException('Inventory item not found');
    }

    return item;
  }

  async update(id: string, updateInventoryItemDto: UpdateInventoryItemDto) {
    const existingItem = await this.findOne(id);

    // Update status based on quantity if quantity is being updated
    let status = updateInventoryItemDto.status;
    if (updateInventoryItemDto.quantity !== undefined && !status) {
      const minQuantity =
        updateInventoryItemDto.minQuantity ?? existingItem.minQuantity;
      if (updateInventoryItemDto.quantity === 0) {
        status = InventoryStatus.OUT_OF_STOCK;
      } else if (updateInventoryItemDto.quantity <= minQuantity) {
        status = InventoryStatus.LOW_STOCK;
      } else {
        status = InventoryStatus.IN_STOCK;
      }
    }

    const updatedData: any = { ...updateInventoryItemDto };
    if (status) {
      updatedData.status = status;
    }

    const item = await this.prisma.inventoryItem.update({
      where: { id },
      data: updatedData,
      include: {
        createdBy: {
          select: {
            id: true,
            username: true,
            role: true,
          },
        },
      },
    });

    return item;
  }

  async remove(id: string) {
    await this.findOne(id); // Check if exists

    await this.prisma.inventoryItem.delete({
      where: { id },
    });

    return { message: 'Inventory item deleted successfully' };
  }

  async getLowStockItems() {
    const items = await this.prisma.inventoryItem.findMany({
      where: {
        OR: [
          { status: InventoryStatus.LOW_STOCK },
          { status: InventoryStatus.OUT_OF_STOCK },
        ],
      },
      include: {
        createdBy: {
          select: {
            id: true,
            username: true,
            role: true,
          },
        },
      },
      orderBy: {
        quantity: 'asc',
      },
    });

    return items;
  }

  async getStats() {
    const [total, inStock, lowStock, outOfStock] = await Promise.all([
      this.prisma.inventoryItem.count(),
      this.prisma.inventoryItem.count({
        where: { status: InventoryStatus.IN_STOCK },
      }),
      this.prisma.inventoryItem.count({
        where: { status: InventoryStatus.LOW_STOCK },
      }),
      this.prisma.inventoryItem.count({
        where: { status: InventoryStatus.OUT_OF_STOCK },
      }),
    ]);

    return {
      total,
      inStock,
      lowStock,
      outOfStock,
    };
  }
}

import {
  IsNotEmpty,
  IsString,
  IsOptional,
  IsNumber,
  IsDecimal,
  IsEnum,
  Min,
} from 'class-validator';
import { Transform } from 'class-transformer';
import { InventoryStatus } from '@prisma/client';

export class CreateInventoryItemDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsNotEmpty()
  @IsString()
  sku: string;

  @IsNumber()
  @Min(0)
  @Transform(({ value }) => parseInt(value))
  quantity: number;

  @IsNumber()
  @Min(0)
  @Transform(({ value }) => parseInt(value))
  minQuantity: number;

  @IsNotEmpty()
  @Transform(({ value }) => parseFloat(value))
  price: number;

  @IsOptional()
  @IsString()
  category?: string;

  @IsOptional()
  @IsString()
  location?: string;

  @IsOptional()
  @IsEnum(InventoryStatus)
  status?: InventoryStatus;
}

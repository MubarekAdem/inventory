import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'inventory_item.g.dart';

enum InventoryStatus {
  @JsonValue('IN_STOCK')
  inStock,
  @JsonValue('OUT_OF_STOCK')
  outOfStock,
  @JsonValue('LOW_STOCK')
  lowStock,
}

@JsonSerializable()
class InventoryItem {
  final String id;
  final String name;
  final String? description;
  final String sku;
  final int quantity;
  final int minQuantity;
  final double price;
  final String? category;
  final String? location;
  final InventoryStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User createdBy;

  const InventoryItem({
    required this.id,
    required this.name,
    this.description,
    required this.sku,
    required this.quantity,
    required this.minQuantity,
    required this.price,
    this.category,
    this.location,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryItemToJson(this);
}

@JsonSerializable()
class InventoryResponse {
  final List<InventoryItem> items;
  final Pagination pagination;

  const InventoryResponse({required this.items, required this.pagination});

  factory InventoryResponse.fromJson(Map<String, dynamic> json) =>
      _$InventoryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryResponseToJson(this);
}

@JsonSerializable()
class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}

@JsonSerializable()
class InventoryStats {
  final int total;
  final int inStock;
  final int lowStock;
  final int outOfStock;

  const InventoryStats({
    required this.total,
    required this.inStock,
    required this.lowStock,
    required this.outOfStock,
  });

  factory InventoryStats.fromJson(Map<String, dynamic> json) =>
      _$InventoryStatsFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryStatsToJson(this);
}

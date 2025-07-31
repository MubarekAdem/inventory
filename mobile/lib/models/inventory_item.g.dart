// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) =>
    InventoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sku: json['sku'] as String,
      quantity: (json['quantity'] as num).toInt(),
      minQuantity: (json['minQuantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String?,
      location: json['location'] as String?,
      status: $enumDecode(_$InventoryStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: User.fromJson(json['createdBy'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InventoryItemToJson(InventoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'sku': instance.sku,
      'quantity': instance.quantity,
      'minQuantity': instance.minQuantity,
      'price': instance.price,
      'category': instance.category,
      'location': instance.location,
      'status': _$InventoryStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
    };

const _$InventoryStatusEnumMap = {
  InventoryStatus.inStock: 'IN_STOCK',
  InventoryStatus.outOfStock: 'OUT_OF_STOCK',
  InventoryStatus.lowStock: 'LOW_STOCK',
};

InventoryResponse _$InventoryResponseFromJson(Map<String, dynamic> json) =>
    InventoryResponse(
      items:
          (json['items'] as List<dynamic>)
              .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$InventoryResponseToJson(InventoryResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'pagination': instance.pagination,
    };

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
);

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
    };

InventoryStats _$InventoryStatsFromJson(Map<String, dynamic> json) =>
    InventoryStats(
      total: (json['total'] as num).toInt(),
      inStock: (json['inStock'] as num).toInt(),
      lowStock: (json['lowStock'] as num).toInt(),
      outOfStock: (json['outOfStock'] as num).toInt(),
    );

Map<String, dynamic> _$InventoryStatsToJson(InventoryStats instance) =>
    <String, dynamic>{
      'total': instance.total,
      'inStock': instance.inStock,
      'lowStock': instance.lowStock,
      'outOfStock': instance.outOfStock,
    };

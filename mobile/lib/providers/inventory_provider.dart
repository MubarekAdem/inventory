import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/inventory_item.dart';

class InventoryState {
  final List<InventoryItem> items;
  final InventoryStats? stats;
  final Pagination? pagination;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? selectedCategory;
  final InventoryStatus? selectedStatus;

  const InventoryState({
    this.items = const [],
    this.stats,
    this.pagination,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedStatus,
  });

  InventoryState copyWith({
    List<InventoryItem>? items,
    InventoryStats? stats,
    Pagination? pagination,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedCategory,
    InventoryStatus? selectedStatus,
  }) {
    return InventoryState(
      items: items ?? this.items,
      stats: stats ?? this.stats,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}

class InventoryNotifier extends StateNotifier<InventoryState> {
  InventoryNotifier() : super(const InventoryState()) {
    loadItems();
    loadStats();
  }

  Future<void> loadItems({int page = 1}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': '10',
      };

      if (state.searchQuery.isNotEmpty) {
        queryParams['search'] = state.searchQuery;
      }
      if (state.selectedCategory != null &&
          state.selectedCategory!.isNotEmpty) {
        queryParams['category'] = state.selectedCategory!;
      }
      if (state.selectedStatus != null) {
        queryParams['status'] = state.selectedStatus!.name.toUpperCase();
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await ApiService.get('/inventory?$queryString');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final inventoryResponse = InventoryResponse.fromJson(data);

        state = state.copyWith(
          items:
              page == 1
                  ? inventoryResponse.items
                  : [...state.items, ...inventoryResponse.items],
          pagination: inventoryResponse.pagination,
          isLoading: false,
        );
      } else {
        final error = json.decode(response.body);
        state = state.copyWith(
          isLoading: false,
          error: error['message'] ?? 'Failed to load inventory',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<void> loadStats() async {
    try {
      final response = await ApiService.get('/inventory/stats');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final stats = InventoryStats.fromJson(data);
        state = state.copyWith(stats: stats);
      }
    } catch (e) {
      // Stats loading failure shouldn't affect main UI
      print('Failed to load stats: $e');
    }
  }

  Future<bool> createItem(Map<String, dynamic> itemData) async {
    try {
      final response = await ApiService.post('/inventory', itemData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadItems(); // Refresh the list
        await loadStats(); // Refresh stats
        return true;
      } else {
        final error = json.decode(response.body);
        state = state.copyWith(
          error: error['message'] ?? 'Failed to create item',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Network error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateItem(String id, Map<String, dynamic> itemData) async {
    try {
      final response = await ApiService.patch('/inventory/$id', itemData);

      if (response.statusCode == 200) {
        await loadItems(); // Refresh the list
        await loadStats(); // Refresh stats
        return true;
      } else {
        final error = json.decode(response.body);
        state = state.copyWith(
          error: error['message'] ?? 'Failed to update item',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Network error: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      final response = await ApiService.delete('/inventory/$id');

      if (response.statusCode == 200) {
        await loadItems(); // Refresh the list
        await loadStats(); // Refresh stats
        return true;
      } else {
        final error = json.decode(response.body);
        state = state.copyWith(
          error: error['message'] ?? 'Failed to delete item',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: 'Network error: ${e.toString()}');
      return false;
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadItems(); // Reload with new search
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
    loadItems(); // Reload with new filter
  }

  void setStatus(InventoryStatus? status) {
    state = state.copyWith(selectedStatus: status);
    loadItems(); // Reload with new filter
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void refresh() {
    loadItems();
    loadStats();
  }
}

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
      return InventoryNotifier();
    });

// Provider for low stock items
final lowStockItemsProvider = FutureProvider<List<InventoryItem>>((ref) async {
  try {
    final response = await ApiService.get('/inventory/low-stock');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((item) => InventoryItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load low stock items');
    }
  } catch (e) {
    throw Exception('Network error: ${e.toString()}');
  }
});

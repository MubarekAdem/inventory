import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';
import '../widgets/app_drawer.dart';
import '../widgets/inventory_item_card.dart';
import '../widgets/add_edit_inventory_dialog.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  InventoryStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddEditInventoryDialog(),
    );
  }

  void _showEditItemDialog(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AddEditInventoryDialog(item: item),
    );
  }

  void _showDeleteConfirmation(InventoryItem item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Item'),
            content: Text('Are you sure you want to delete "${item.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final success = await ref
                      .read(inventoryProvider.notifier)
                      .deleteItem(item.id);
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Item deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, SKU, or description...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(inventoryProvider.notifier)
                                .setSearchQuery('');
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                ref.read(inventoryProvider.notifier).setSearchQuery(value);
              },
            ),
            const SizedBox(height: 16),

            // Filter chips
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      DropdownMenuItem(
                        value: 'Electronics',
                        child: Text('Electronics'),
                      ),
                      DropdownMenuItem(
                        value: 'Clothing',
                        child: Text('Clothing'),
                      ),
                      DropdownMenuItem(value: 'Books', child: Text('Books')),
                      DropdownMenuItem(value: 'Home', child: Text('Home')),
                      DropdownMenuItem(value: 'Sports', child: Text('Sports')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      ref.read(inventoryProvider.notifier).setCategory(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<InventoryStatus>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Status')),
                      DropdownMenuItem(
                        value: InventoryStatus.inStock,
                        child: Text('In Stock'),
                      ),
                      DropdownMenuItem(
                        value: InventoryStatus.lowStock,
                        child: Text('Low Stock'),
                      ),
                      DropdownMenuItem(
                        value: InventoryStatus.outOfStock,
                        child: Text('Out of Stock'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                      ref.read(inventoryProvider.notifier).setStatus(value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryProvider);

    // Listen for errors
    ref.listen<InventoryState>(inventoryProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ref.read(inventoryProvider.notifier).clearError();
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(inventoryProvider.notifier).refresh();
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(inventoryProvider.notifier).refresh();
        },
        child: Column(
          children: [
            // Filters
            _buildFilters(),

            // Items list
            Expanded(
              child:
                  inventoryState.items.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              inventoryState.isLoading
                                  ? 'Loading inventory...'
                                  : 'No items found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (inventoryState.isLoading)
                              const Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: SpinKitThreeBounce(
                                  color: Colors.blue,
                                  size: 30,
                                ),
                              ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount:
                            inventoryState.items.length +
                            (inventoryState.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == inventoryState.items.length) {
                            // Loading indicator at the bottom
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: SpinKitThreeBounce(
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                            );
                          }

                          final item = inventoryState.items[index];
                          return InventoryItemCard(
                            item: item,
                            onEdit: () => _showEditItemDialog(item),
                            onDelete: () => _showDeleteConfirmation(item),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

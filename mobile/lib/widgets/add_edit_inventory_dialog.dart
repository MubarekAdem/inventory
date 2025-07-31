import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';

class AddEditInventoryDialog extends ConsumerStatefulWidget {
  final InventoryItem? item;

  const AddEditInventoryDialog({Key? key, this.item}) : super(key: key);

  @override
  ConsumerState<AddEditInventoryDialog> createState() =>
      _AddEditInventoryDialogState();
}

class _AddEditInventoryDialogState
    extends ConsumerState<AddEditInventoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skuController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minQuantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();

  InventoryStatus _selectedStatus = InventoryStatus.inStock;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final item = widget.item!;
    _nameController.text = item.name;
    _descriptionController.text = item.description ?? '';
    _skuController.text = item.sku;
    _quantityController.text = item.quantity.toString();
    _minQuantityController.text = item.minQuantity.toString();
    _priceController.text = item.price.toString();
    _categoryController.text = item.category ?? '';
    _locationController.text = item.location ?? '';
    _selectedStatus = item.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _quantityController.dispose();
    _minQuantityController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final itemData = {
      'name': _nameController.text.trim(),
      'description':
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      'sku': _skuController.text.trim(),
      'quantity': int.parse(_quantityController.text),
      'minQuantity': int.parse(_minQuantityController.text),
      'price': double.parse(_priceController.text),
      'category':
          _categoryController.text.trim().isEmpty
              ? null
              : _categoryController.text.trim(),
      'location':
          _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
      'status': _selectedStatus.name.toUpperCase(),
    };

    bool success;
    if (widget.item != null) {
      success = await ref
          .read(inventoryProvider.notifier)
          .updateItem(widget.item!.id, itemData);
    } else {
      success = await ref.read(inventoryProvider.notifier).createItem(itemData);
    }

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.item != null
                ? 'Item updated successfully'
                : 'Item created successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item != null ? 'Edit Item' : 'Add New Item',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Form fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Name and SKU
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Item Name *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Name is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _skuController,
                              decoration: const InputDecoration(
                                labelText: 'SKU *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'SKU is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Quantity and Min Quantity
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Quantity *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Quantity is required';
                                }
                                if (int.tryParse(value) == null ||
                                    int.parse(value) < 0) {
                                  return 'Enter valid quantity';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _minQuantityController,
                              decoration: const InputDecoration(
                                labelText: 'Min Quantity *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Min quantity is required';
                                }
                                if (int.tryParse(value) == null ||
                                    int.parse(value) < 0) {
                                  return 'Enter valid min quantity';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Price
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price *',
                          prefixText: '\$ ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Price is required';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) < 0) {
                            return 'Enter valid price';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category and Location
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _categoryController,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Location',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status
                      DropdownButtonFormField<InventoryStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
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
                          if (value != null) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveItem,
                      child:
                          _isLoading
                              ? const SpinKitThreeBounce(
                                color: Colors.white,
                                size: 20,
                              )
                              : Text(
                                widget.item != null ? 'Update' : 'Add Item',
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

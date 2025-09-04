import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const HafizBiryaniPOSApp());
}

class HafizBiryaniPOSApp extends StatelessWidget {
  const HafizBiryaniPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hafiz Chicken Tikka Biryani POS',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto',
      ),
      home: const BillingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final List<OrderItem> _orderItems = [];
  double _deliveryCharge = 0.0;
  String _orderType = 'Dine-in';
  String _paymentMethod = 'Cash';
  
  final List<String> _orderTypes = ['Dine-in', 'Takeaway', 'Delivery'];
  final List<String> _paymentMethods = ['Cash', 'JazzCash', 'Easypaisa', 'Other'];
  
  final List<MenuItem> _menuItems = [
    MenuItem(name: 'Chicken Tikka Biryani', price: 480.0, unit: 'kg'),
    MenuItem(name: 'Raita', price: 60.0, unit: 'unit'),
    MenuItem(name: 'Salad', price: 60.0, unit: 'unit'),
  ];

  void _addNewItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddItemDialog(
          menuItems: _menuItems,
          onItemAdded: (OrderItem newItem) {
            setState(() {
              _orderItems.add(newItem);
            });
          },
        );
      },
    );
  }

  double get _subTotal {
    return _orderItems.fold(0.0, (sum, item) => sum + item.total);
  }

  double get _total {
    return _subTotal + _deliveryCharge;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hafiz Chicken Tikka Biryani POS'),
        backgroundColor: Colors.orange[700],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMMM yyyy').format(DateTime.now()),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Bill #: 001',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _orderType,
                    items: _orderTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _orderType = newValue!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Order Type',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    items: _paymentMethods.map((String method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _paymentMethod = newValue!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: _orderItems.length,
              itemBuilder: (context, index) {
                final item = _orderItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('${item.quantity} ${item.unit} - Rs. ${item.total.toStringAsFixed(0)}'),
                );
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:'),
                    Text('Rs. ${_subTotal.toStringAsFixed(0)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('Rs. ${_total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[300],
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                    onPressed: _addNewItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItem {
  final String name;
  final double price;
  final String unit;

  MenuItem({required this.name, required this.price, required this.unit});
}

class OrderItem {
  final String name;
  final double price;
  final String unit;
  final double quantity;

  OrderItem({
    required this.name,
    required this.price,
    required this.unit,
    required this.quantity,
  });

  double get total => price * quantity;
}

class AddItemDialog extends StatefulWidget {
  final List<MenuItem> menuItems;
  final Function(OrderItem) onItemAdded;

  const AddItemDialog({
    super.key,
    required this.menuItems,
    required this.onItemAdded,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  String _selectedItem = '';
  double _quantity = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.menuItems.isNotEmpty) {
      _selectedItem = widget.menuItems.first.name;
    }
  }

  void _addItem() {
    final selected = widget.menuItems.firstWhere((item) => item.name == _selectedItem);
    final newItem = OrderItem(
      name: selected.name,
      price: selected.price,
      unit: selected.unit,
      quantity: _quantity,
    );
    widget.onItemAdded(newItem);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Item',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedItem,
              items: widget.menuItems.map((MenuItem item) {
                return DropdownMenuItem<String>(
                  value: item.name,
                  child: Text(item.name),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedItem = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Item',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.number,
              initialValue: '1',
              onChanged: (value) {
                _quantity = double.tryParse(value) ?? 1.0;
              },
              decoration: const InputDecoration(
                labelText: 'Quantity',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _addItem,
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
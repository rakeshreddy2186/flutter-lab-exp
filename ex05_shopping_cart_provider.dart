// Ex.5 - Application State Management (Theme: Shopping Cart using Provider)
// pubspec.yaml dependencies:  provider: ^6.1.2
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Product {
  final String name;
  final double price;
  final IconData icon;
  const Product(this.name, this.price, this.icon);
}

class CartItem {
  final Product product;
  int quantity;
  CartItem(this.product, this.quantity);
  double get total => product.price * quantity;
}

const List<Product> catalog = [
  Product('Notebook', 60, Icons.menu_book),
  Product('Pen Pack', 40, Icons.edit),
  Product('Calculator', 450, Icons.calculate),
  Product('Backpack', 1200, Icons.backpack),
  Product('Water Bottle', 350, Icons.water_drop),
];

// State holder - notifies the UI whenever data changes
class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  double get subtotal => _items.fold<double>(0, (s, i) => s + i.total);
  double get discount => subtotal > 2000 ? subtotal * 0.10 : 0;
  double get grandTotal => subtotal - discount;
  int get itemCount => _items.fold<int>(0, (s, i) => s + i.quantity);

  void add(Product p) {
    final index = _items.indexWhere((i) => i.product.name == p.name);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(p, 1));
    }
    notifyListeners();
  }

  void decrease(int index) {
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void remove(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartModel(),
      child: const CartApp(),
    ),
  );
}

class CartApp extends StatelessWidget {
  const CartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Cart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const CartPage(),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Store'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Badge(
              label: Text('${cart.itemCount}'),
              isLabelVisible: cart.itemCount > 0,
              child: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 230,
            child: ListView.builder(
              itemCount: catalog.length,
              itemBuilder: (context, i) {
                final p = catalog[i];
                return ListTile(
                  leading: Icon(p.icon),
                  title: Text(p.name),
                  subtitle: Text('₹${p.price.toStringAsFixed(0)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    // read() inside event handlers
                    onPressed: () => context.read<CartModel>().add(p),
                  ),
                );
              },
            ),
          ),
          const Divider(thickness: 2),
          const Text('Your Cart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Cart is empty'))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, i) {
                      final item = cart.items[i];
                      return ListTile(
                        title: Text(item.product.name),
                        subtitle: Text(
                            '₹${item.product.price.toStringAsFixed(0)} x ${item.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('₹${item.total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () =>
                                  context.read<CartModel>().decrease(i),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  context.read<CartModel>().remove(i),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                _row('Subtotal', cart.subtotal),
                _row('Discount (10% above ₹2000)', -cart.discount),
                const Divider(),
                _row('Grand Total', cart.grandTotal, bold: true),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: cart.items.isEmpty
                        ? null
                        : () => context.read<CartModel>().clear(),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Cart'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double value, {bool bold = false}) {
    final style = TextStyle(
        fontSize: bold ? 18 : 14,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('₹${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}

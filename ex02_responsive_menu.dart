// Ex.2 - Adaptive and Responsive UI Design (Theme: Restaurant Menu)
// pubspec.yaml: no extra packages needed
import 'package:flutter/material.dart';

void main() => runApp(const MenuApp());

class Dish {
  final String name;
  final String type;
  final double price;
  final double rating;
  final IconData icon;
  const Dish(this.name, this.type, this.price, this.rating, this.icon);
}

const List<Dish> dishes = [
  Dish('Margherita Pizza', 'Main Course', 249, 4.5, Icons.local_pizza),
  Dish('Veg Burger', 'Fast Food', 129, 4.1, Icons.lunch_dining),
  Dish('Chocolate Cake', 'Dessert', 99, 4.7, Icons.cake),
  Dish('Ice Cream', 'Dessert', 79, 4.3, Icons.icecream),
  Dish('Filter Coffee', 'Beverage', 40, 4.8, Icons.coffee),
  Dish('Ramen Bowl', 'Main Course', 299, 4.4, Icons.ramen_dining),
  Dish('Fresh Juice', 'Beverage', 70, 4.0, Icons.local_drink),
  Dish('Breakfast Combo', 'Breakfast', 149, 4.2, Icons.free_breakfast),
];

class MenuApp extends StatelessWidget {
  const MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Menu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      home: const MenuPage(),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Menu')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          final int columns = w >= 1000 ? 4 : (w >= 700 ? 3 : 2);
          final String device =
              w >= 1000 ? 'Desktop' : (w >= 700 ? 'Tablet' : 'Mobile');

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Width: ${w.toInt()} px  |  Layout: $device  |  Columns: $columns',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: w >= 700 ? 1.0 : 0.8,
                  ),
                  itemCount: dishes.length,
                  itemBuilder: (context, i) => DishCard(dish: dishes[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Reusable card - designed once, used for every dish
class DishCard extends StatelessWidget {
  final Dish dish;
  const DishCard({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(dish.icon, size: 48, color: scheme.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(dish.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(dish.type, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹${dish.price.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: scheme.primary)),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(' ${dish.rating}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

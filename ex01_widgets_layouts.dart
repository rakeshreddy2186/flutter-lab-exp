// Ex.1 - Working with Widgets and Layouts (Theme: Famous Tourist Places)
// pubspec.yaml: no extra packages needed (icons are used instead of images)
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tourist Places',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Famous Places in India',
              style: TextStyle(letterSpacing: 2)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: const [
            PlaceItem(
                name: 'Taj Mahal',
                city: 'Agra',
                entryFee: 50,
                icon: Icons.account_balance),
            PlaceItem(
                name: 'Gateway of India',
                city: 'Mumbai',
                entryFee: 0,
                icon: Icons.location_city),
            PlaceItem(
                name: 'Meenakshi Temple',
                city: 'Madurai',
                entryFee: 0,
                icon: Icons.temple_hindu),
            PlaceItem(
                name: 'Munnar Hills',
                city: 'Kerala',
                entryFee: 30,
                icon: Icons.landscape),
            PlaceItem(
                name: 'Marina Beach',
                city: 'Chennai',
                entryFee: 0,
                icon: Icons.beach_access),
          ],
        ),
      ),
    );
  }
}

// Reusable custom widget for one row of the list
class PlaceItem extends StatelessWidget {
  final String name;
  final String city;
  final double entryFee;
  final IconData icon;

  const PlaceItem({
    super.key,
    required this.name,
    required this.city,
    required this.entryFee,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: scheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(city, style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Entry Fee', style: TextStyle(fontSize: 12)),
                Text(
                  entryFee == 0 ? 'Free' : '₹${entryFee.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: entryFee == 0 ? Colors.green : scheme.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

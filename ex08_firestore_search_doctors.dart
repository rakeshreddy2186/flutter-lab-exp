// Ex.8 - Searching Information in Firestore (Theme: Hospital Doctor Search)
// Setup: flutter pub add firebase_core cloud_firestore ; flutterfire configure
// Create collection "doctors" manually in Firebase Console with fields:
//   id (String), name (String), specialization (String), slots (Number)
// Sample: D101 | Dr. Ravi Kumar | Cardiology | 5
//         D102 | Dr. Anitha S   | Dermatology | 3
//         D103 | Dr. Suresh M   | Orthopedics | 0
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const HospitalApp());
}

class HospitalApp extends StatelessWidget {
  const HospitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const DoctorSearchPage(),
    );
  }
}

class DoctorSearchPage extends StatefulWidget {
  const DoctorSearchPage({super.key});

  @override
  State<DoctorSearchPage> createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {
  final _nameController = TextEditingController();
  Map<String, dynamic>? _doctor;
  String? _message;
  bool _loading = false;

  Future<void> _search() async {
    final input = _nameController.text.trim().toLowerCase();
    if (input.isEmpty) {
      setState(() {
        _doctor = null;
        _message = 'Please enter a doctor name';
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('doctors').get();
      Map<String, dynamic>? found;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        // case-insensitive comparison
        if ((data['name'] ?? '').toString().toLowerCase() == input) {
          found = data;
          break;
        }
      }
      setState(() {
        _doctor = found;
        _message = found == null ? 'Doctor not found' : null;
      });
    } catch (e) {
      setState(() {
        _doctor = null;
        _message = 'Error: $e';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hospital Doctor Search')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Enter doctor name',
                prefixIcon: Icon(Icons.medical_services),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _search,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              ),
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (_message != null)
              Text(_message!,
                  style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            if (_doctor != null) DoctorCard(data: _doctor!),
          ],
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const DoctorCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final int slots = (data['slots'] ?? 0) as int;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${data['name']}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Specialization: ${data['specialization']}'),
            const SizedBox(height: 6),
            Text('Slots Available: $slots'),
            if (slots == 0) ...[
              const SizedBox(height: 10),
              const Text('Not Available - All Slots Booked',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }
}

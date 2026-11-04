// Ex.9 - Update Information in Firestore (Theme: Update Doctor Appointment Slots)
// Uses the same "doctors" collection created for Ex.8 (id, name, specialization, slots)
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
      title: 'Update Slots',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const UpdateSlotsPage(),
    );
  }
}

class UpdateSlotsPage extends StatefulWidget {
  const UpdateSlotsPage({super.key});

  @override
  State<UpdateSlotsPage> createState() => _UpdateSlotsPageState();
}

class _UpdateSlotsPageState extends State<UpdateSlotsPage> {
  final _nameController = TextEditingController();
  final _slotsController = TextEditingController();

  DocumentReference<Map<String, dynamic>>? _reference;
  Map<String, dynamic>? _doctor;
  String? _message;

  Future<void> _search() async {
    final input = _nameController.text.trim().toLowerCase();
    if (input.isEmpty) {
      setState(() => _message = 'Please enter a doctor name');
      return;
    }
    final snapshot =
        await FirebaseFirestore.instance.collection('doctors').get();
    QueryDocumentSnapshot<Map<String, dynamic>>? match;
    for (final doc in snapshot.docs) {
      if ((doc.data()['name'] ?? '').toString().toLowerCase() == input) {
        match = doc;
        break;
      }
    }
    setState(() {
      if (match == null) {
        _reference = null;
        _doctor = null;
        _message = 'Doctor not found';
      } else {
        _reference = match.reference; // stored for the update step
        _doctor = match.data();
        _message = null;
      }
    });
  }

  Future<void> _update() async {
    if (_reference == null) {
      setState(() => _message = 'Search for a doctor first');
      return;
    }
    final newSlots = int.tryParse(_slotsController.text.trim());
    if (newSlots == null || newSlots < 0) {
      setState(() => _message = 'Enter a valid number of slots (0 or more)');
      return;
    }
    await _reference!.update({'slots': newSlots}); // only this field changes
    final fresh = await _reference!.get(); // read again to show new value
    setState(() {
      _doctor = fresh.data();
      _message = 'Slots updated successfully';
      _slotsController.clear();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool success = _message == 'Slots updated successfully';
    return Scaffold(
      appBar: AppBar(title: const Text('Update Doctor Slots')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Doctor name',
                prefixIcon: Icon(Icons.person_search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _search,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _slotsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New slots available',
                prefixIcon: Icon(Icons.event_available),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: _update,
                icon: const Icon(Icons.update),
                label: const Text('Update'),
              ),
            ),
            const SizedBox(height: 16),
            if (_message != null)
              Text(_message!,
                  style: TextStyle(
                      color: success ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600)),
            if (_doctor != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${_doctor!['name']}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('Specialization: ${_doctor!['specialization']}'),
                      const SizedBox(height: 6),
                      Text('Slots Available: ${_doctor!['slots']}'),
                      if ((_doctor!['slots'] ?? 0) == 0)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('Not Available - All Slots Booked',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

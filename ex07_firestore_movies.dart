// Ex.7 - Data Persistence using Google Cloud Firestore (Theme: Movie Records)
// Setup: flutter pub add firebase_core cloud_firestore ; flutterfire configure
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Records',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true),
      home: const MoviePage(),
    );
  }
}

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _directorController = TextEditingController();
  final _yearController = TextEditingController();
  final _ratingController = TextEditingController();

  final CollectionReference _movies =
      FirebaseFirestore.instance.collection('movies');

  Future<void> _addMovie() async {
    if (!_formKey.currentState!.validate()) return;
    await _movies.add({
      'title': _titleController.text.trim(),
      'director': _directorController.text.trim(),
      'year': int.parse(_yearController.text.trim()),
      'rating': double.parse(_ratingController.text.trim()),
    });
    _titleController.clear();
    _directorController.clear();
    _yearController.clear();
    _ratingController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Movie saved to Firestore')));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _directorController.dispose();
    _yearController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Widget _field(TextEditingController c, String label,
      {TextInputType? type, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        decoration:
            InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: validator ??
            (v) => (v == null || v.trim().isEmpty) ? 'Enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movie Records (Firestore)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _field(_titleController, 'Title'),
                  _field(_directorController, 'Director'),
                  Row(
                    children: [
                      Expanded(
                        child: _field(_yearController, 'Year',
                            type: TextInputType.number, validator: (v) {
                          final y = int.tryParse(v ?? '');
                          if (y == null || y < 1900 || y > 2100) {
                            return 'Enter a valid year';
                          }
                          return null;
                        }),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _field(_ratingController, 'Rating (0-10)',
                            type: const TextInputType.numberWithOptions(
                                decimal: true), validator: (v) {
                          final r = double.tryParse(v ?? '');
                          if (r == null || r < 0 || r > 10) {
                            return 'Enter 0 to 10';
                          }
                          return null;
                        }),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _addMovie,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Add Movie'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            // Listens to live changes in the collection
            child: StreamBuilder<QuerySnapshot>(
              stream: _movies.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No movies stored yet'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final m = docs[i].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.movie)),
                        title: Text('${m['title']}'),
                        subtitle:
                            Text('Director: ${m['director']}  •  ${m['year']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            Text(' ${m['rating']}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

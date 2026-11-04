// Ex.6 - Data Persistence using SQLite (Theme: Contact Book - Create & Read)
// pubspec.yaml dependencies:  sqflite: ^2.3.3   path: ^1.9.0
// Run on Android / iOS emulator or device (not Flutter Web).
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Contact {
  final int? id;
  final String name;
  final String phone;
  final String email;

  Contact({this.id, required this.name, required this.phone, required this.email});

  Map<String, dynamic> toMap() =>
      {'id': id, 'name': name, 'phone': phone, 'email': email};

  factory Contact.fromMap(Map<String, dynamic> m) => Contact(
        id: m['id'] as int?,
        name: m['name'] as String,
        phone: m['phone'] as String,
        email: m['email'] as String,
      );
}

// Singleton database helper
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'contacts.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE contacts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT NOT NULL,
          email TEXT NOT NULL
        )
      '''),
    );
  }

  // CREATE
  Future<int> insertContact(Contact c) async {
    final db = await database;
    return db.insert('contacts', c.toMap()..remove('id'));
  }

  // READ
  Future<List<Contact>> getContacts() async {
    final db = await database;
    final rows = await db.query('contacts', orderBy: 'name COLLATE NOCASE');
    return rows.map(Contact.fromMap).toList();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ContactApp());
}

class ContactApp extends StatelessWidget {
  const ContactApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Book',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.cyan, useMaterial3: true),
      home: const ContactPage(),
    );
  }
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final data = await DatabaseHelper.instance.getContacts();
    setState(() => _contacts = data);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await DatabaseHelper.instance.insertContact(Contact(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
    ));
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    await _loadContacts();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Contact saved')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Book (SQLite)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                        labelText: 'Name', border: OutlineInputBorder()),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'Phone', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().length != 10)
                        ? 'Enter a 10-digit phone number'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: 'Email', border: OutlineInputBorder()),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Contact'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: _contacts.isEmpty
                ? const Center(child: Text('No contacts saved yet'))
                : ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, i) {
                      final c = _contacts[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(child: Text(c.name[0])),
                          title: Text(c.name),
                          subtitle: Text('${c.phone}\n${c.email}'),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

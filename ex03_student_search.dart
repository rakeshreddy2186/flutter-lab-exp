// Ex.3 - Interactivity: Input and Forms (Theme: Student Directory Search & Filter)
// pubspec.yaml: no extra packages needed
import 'package:flutter/material.dart';

void main() => runApp(const StudentSearchApp());

class Student {
  final String name;
  final String regNo;
  final String department;
  final double cgpa;
  const Student(this.name, this.regNo, this.department, this.cgpa);
}

const List<Student> allStudents = [
  Student('Aarav Kumar', 'URK23CS1001', 'CSE', 8.7),
  Student('Divya S', 'URK23CS1002', 'CSE', 9.1),
  Student('Karthik R', 'URK23EC2001', 'ECE', 7.9),
  Student('Meena P', 'URK23EC2002', 'ECE', 8.4),
  Student('Rahul M', 'URK23ME3001', 'MECH', 7.5),
  Student('Sneha V', 'URK23ME3002', 'MECH', 8.0),
  Student('Arjun T', 'URK23AI4001', 'AI&DS', 9.3),
  Student('Priya L', 'URK23AI4002', 'AI&DS', 8.8),
];

class StudentSearchApp extends StatelessWidget {
  const StudentSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const StudentSearchPage(),
    );
  }
}

class StudentSearchPage extends StatefulWidget {
  const StudentSearchPage({super.key});

  @override
  State<StudentSearchPage> createState() => _StudentSearchPageState();
}

class _StudentSearchPageState extends State<StudentSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _departments = ['All', 'CSE', 'ECE', 'MECH', 'AI&DS'];
  String _query = '';
  String _selectedDept = 'All';

  List<Student> get _filteredStudents {
    return allStudents.where((s) {
      final q = _query.toLowerCase();
      final matchesText = s.name.toLowerCase().contains(q) ||
          s.regNo.toLowerCase().contains(q);
      final matchesDept =
          _selectedDept == 'All' || s.department == _selectedDept;
      return matchesText && matchesDept;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredStudents;
    return Scaffold(
      appBar: AppBar(title: const Text('Student Search & Filter')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or register number',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _departments
                    .map((d) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(d),
                            selected: _selectedDept == d,
                            onSelected: (_) =>
                                setState(() => _selectedDept = d),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('${results.length} student(s) found',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('No students found'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, i) {
                        final s = results[i];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text(s.name[0])),
                            title: Text(s.name),
                            subtitle: Text('${s.regNo}  •  ${s.department}'),
                            trailing: Text('CGPA ${s.cgpa}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
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

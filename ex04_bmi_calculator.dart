// Ex.4 - Form Validation using Stateful Widgets (Theme: BMI Calculator)
// pubspec.yaml: no extra packages needed
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const BmiApp());

class BmiApp extends StatelessWidget {
  const BmiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.pink, useMaterial3: true),
      home: const BmiCalculator(),
    );
  }
}

class BmiCalculator extends StatefulWidget {
  const BmiCalculator({super.key});

  @override
  State<BmiCalculator> createState() => _BmiCalculatorState();
}

class _BmiCalculatorState extends State<BmiCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  double? _bmi;

  String? _validate(String? value, String label, double min, double max) {
    if (value == null || value.trim().isEmpty) return 'Please enter $label';
    final number = double.tryParse(value.trim());
    if (number == null) return 'Enter a valid number';
    if (number <= 0) return '$label must be greater than 0';
    if (number < min || number > max) {
      return '$label should be between $min and $max';
    }
    return null;
  }

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      final heightM = double.parse(_heightController.text.trim()) / 100;
      final weight = double.parse(_weightController.text.trim());
      setState(() => _bmi = weight / (heightM * heightM));
    }
  }

  void _reset() {
    _formKey.currentState!.reset();
    _heightController.clear();
    _weightController.clear();
    setState(() => _bmi = null);
  }

  String _category(double b) {
    if (b < 18.5) return 'Underweight';
    if (b < 25) return 'Normal';
    if (b < 30) return 'Overweight';
    return 'Obese';
  }

  Color _color(double b) {
    if (b < 18.5) return Colors.blue;
    if (b < 25) return Colors.green;
    if (b < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputFormatters = [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('BMI Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.monitor_weight, size: 70, color: Colors.pink),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: inputFormatters,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  prefixIcon: Icon(Icons.height),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validate(v, 'Height', 50, 250),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: inputFormatters,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  prefixIcon: Icon(Icons.fitness_center),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validate(v, 'Weight', 10, 300),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                        onPressed: _calculate, child: const Text('Calculate')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                        onPressed: _reset, child: const Text('Reset')),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_bmi != null)
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('Your BMI', style: TextStyle(fontSize: 16)),
                        Text(_bmi!.toStringAsFixed(1),
                            style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: _color(_bmi!))),
                        Text(_category(_bmi!),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: _color(_bmi!))),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

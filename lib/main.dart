import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _display = '0';
        _expression = '';
      } else if (value == '=') {
        // TODO: Implement calculation logic
        _display = 'Result';
      } else {
        if (_display == '0') {
          _display = value;
        } else {
          _display += value;
        }
        _expression += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Display area
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _display,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Button area - placeholder for now
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                children: [
                  _buildButton('C'),
                  _buildButton('±'),
                  _buildButton('%'),
                  _buildButton('÷'),
                  _buildButton('7'),
                  _buildButton('8'),
                  _buildButton('9'),
                  _buildButton('×'),
                  _buildButton('4'),
                  _buildButton('5'),
                  _buildButton('6'),
                  _buildButton('-'),
                  _buildButton('1'),
                  _buildButton('2'),
                  _buildButton('3'),
                  _buildButton('+'),
                  _buildButton('0'),
                  _buildButton('0'), // Placeholder for double-width 0
                  _buildButton('.'),
                  _buildButton('='),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text) {
    return ElevatedButton(
      onPressed: () => _onButtonPressed(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: _getButtonColor(text),
        foregroundColor: _getTextColor(text),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 2,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getButtonColor(String text) {
    if (text == 'C' || text == '±' || text == '%') {
      return Colors.grey.shade300;
    } else if (text == '÷' || text == '×' || text == '-' || text == '+' || text == '=') {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Colors.grey.shade100;
    }
  }

  Color _getTextColor(String text) {
    if (text == '÷' || text == '×' || text == '-' || text == '+' || text == '=') {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }
}
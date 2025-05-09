// main.dart
import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mile_converter_screen.dart';
import 'history_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _output = '0';
  String _input = '';
  List<String> _history = [];

  void _buttonPressed(String buttonText) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      if (buttonText == 'C') {
        _input = '';
        _output = '0';
      } else if (buttonText == '=') {
        try {
          final replacedInput = _input.replaceAll('x', '*').replaceAll('÷', '/');
          final expression = Expression.parse(replacedInput);
          final evaluator = ExpressionEvaluator();
          final result = evaluator.eval(expression, {});
          _output = result.toString();

          final timestamp = DateTime.now().toString().substring(0, 16);
          final record = '$_input = $_output @ $timestamp';
          _history.add(record);
          prefs.setStringList('history', _history);
        } catch (e) {
          _output = 'Error';
        }
      } else {
        _input += buttonText;
        _output = _input;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('history') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Calculator'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HistoryScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              _output,
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildButtonRow(['7', '8', '9', '÷']),
            _buildButtonRow(['4', '5', '6', 'x']),
            _buildButtonRow(['1', '2', '3', '-']),
            _buildButtonRow(['C', '0', '=', '+']),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MileConverterScreen()),
              ),
              child: Text('Go to Converter'),
            ),
          ],
        ),
      ),
    );
  }

  Row _buildButtonRow(List<String> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons.map((btn) => _buildButton(btn)).toList(),
    );
  }

  Widget _buildButton(String buttonText) {
    return ElevatedButton(
      onPressed: () => _buttonPressed(buttonText),
      child: Text(
        buttonText,
        style: TextStyle(fontSize: 24),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'mile_converter_screen.dart';
import 'history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }

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
    if (buttonText == 'C') {
      setState(() {
        _input = '';
        _output = '0';
      });
    } else if (buttonText == '=') {
      try {
        final replacedInput = _input.replaceAll('x', '*').replaceAll('÷', '/');
        final expression = Expression.parse(replacedInput);
        final evaluator = ExpressionEvaluator();
        final result = evaluator.eval(expression, {});
        final output = result.toString();
        final timestamp = DateTime.now();

        setState(() {
          _output = output;
          final record = '$_input = $output @ ${timestamp.toString().substring(0, 16)}';
          _history.add(record);
        });

        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance.collection('history').add({
            'uid': uid,
            'expression': _input,
            'result': output,
            'timestamp': timestamp,
          });
        }
      } catch (e) {
        setState(() {
          _output = 'Error';
        });
      }
    } else {
      setState(() {
        _input += buttonText;
        _output = _input;
      });
    }
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

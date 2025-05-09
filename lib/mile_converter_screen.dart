import 'package:flutter/material.dart';

class MileConverterScreen extends StatefulWidget {
  @override
  _MileConverterScreenState createState() => _MileConverterScreenState();
}

class _MileConverterScreenState extends State<MileConverterScreen> {
  final TextEditingController _controller = TextEditingController();
  String _output = '0';
  bool _isKilometerToMile = true; // Флаг для переключения между режимами

  // Функция для конвертации
  void _convert() {
    final input = double.tryParse(_controller.text) ?? 0;
    setState(() {
      if (_isKilometerToMile) {
        // Перевод километров в мили
        _output = (input * 0.621371).toStringAsFixed(2);
      } else {
        // Перевод миль в километры
        _output = (input / 0.621371).toStringAsFixed(2);
      }
    });
  }

  // Функция для переключения режима
  void _toggleMode() {
    setState(() {
      _isKilometerToMile = !_isKilometerToMile;
      _controller.clear();
      _output = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isKilometerToMile ? 'Kilometer to Mile Converter' : 'Mile to Kilometer Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Текстовое поле для ввода
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _isKilometerToMile ? 'Enter kilometers' : 'Enter miles',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Кнопка конвертации
            ElevatedButton(
              onPressed: _convert,
              child: Text('Convert'),
            ),
            SizedBox(height: 20),
            // Результат конвертации
            Text(
              _isKilometerToMile ? 'Miles: $_output' : 'Kilometers: $_output',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            // Кнопка для переключения между режимами
            ElevatedButton(
              onPressed: _toggleMode,
              child: Text(_isKilometerToMile ? 'Switch to Mile to Kilometer' : 'Switch to Kilometer to Mile'),
            ),
          ],
        ),
      ),
    );
  }
}

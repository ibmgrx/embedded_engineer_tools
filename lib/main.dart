import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Embedded Engineer Tools',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final conversions = [
      ConversionItem(
        title: 'Dec ↔ Hex',
        icon: Icons.swap_horiz,
        screen: const DecHexScreen(),
      ),
      ConversionItem(
        title: 'Dec ↔ Binary',
        icon: Icons.code,
        screen: const DecBinaryScreen(),
      ),
      ConversionItem(
        title: 'Float → Hex (IEEE 754)',
        icon: Icons.science,
        screen: const FloatToHexScreen(),
      ),
      ConversionItem(
        title: 'Hex → Float',
        icon: Icons.swap_vert,
        screen: const HexToFloatScreen(),
      ),
      ConversionItem(
        title: 'Binary ↔ Hex',
        icon: Icons.hexagon,
        screen: const BinaryHexScreen(),
      ),
      ConversionItem(
        title: 'ASCII ↔ Hex',
        icon: Icons.text_fields,
        screen: const AsciiHexScreen(),
      ),
      ConversionItem(
        title: 'Calculator',
        icon: Icons.calculate,
        screen: const CalculatorScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Embedded Engineer Tools'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
              ),
              itemCount: conversions.length,
              itemBuilder: (context, index) {
                final item = conversions[index];
                return _ConversionCard(item: item);
              },
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '© ibmgrx',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversionCard extends StatelessWidget {
  final ConversionItem item;

  const _ConversionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item.screen),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 48, color: Colors.blue),
            const SizedBox(height: 12),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class ConversionItem {
  final String title;
  final IconData icon;
  final Widget screen;

  ConversionItem({
    required this.title,
    required this.icon,
    required this.screen,
  });
}

// ────────────────────────────────────────────────
// Dec ↔ Hex
// ────────────────────────────────────────────────
class DecHexScreen extends StatefulWidget {
  const DecHexScreen({super.key});

  @override
  State<DecHexScreen> createState() => _DecHexScreenState();
}

class _DecHexScreenState extends State<DecHexScreen> {
  final _decCtrl = TextEditingController();
  final _hexCtrl = TextEditingController();

  void _decToHex() {
    final text = _decCtrl.text.trim();
    if (text.isEmpty) return;
    try {
      final val = int.parse(text);
      _hexCtrl.text = '0x${val.toRadixString(16).toUpperCase()}';
    } catch (_) {
      _hexCtrl.text = 'Invalid';
    }
  }

  void _hexToDec() {
    var text = _hexCtrl.text.trim().replaceAll('0x', '').toUpperCase();
    if (text.isEmpty) return;
    try {
      final val = int.parse(text, radix: 16);
      _decCtrl.text = val.toString();
    } catch (_) {
      _decCtrl.text = 'Invalid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Decimal ↔ Hex')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _decCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Decimal',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _decToHex(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _hexCtrl,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Hex (0x prefix optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _hexToDec(),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Dec ↔ Binary
// ────────────────────────────────────────────────
class DecBinaryScreen extends StatefulWidget {
  const DecBinaryScreen({super.key});

  @override
  State<DecBinaryScreen> createState() => _DecBinaryScreenState();
}

class _DecBinaryScreenState extends State<DecBinaryScreen> {
  final _decCtrl = TextEditingController();
  final _binCtrl = TextEditingController();
  int _bitWidth = 8;

  String _formatBinary(String bin) {
    final padded = bin.padLeft(_bitWidth, '0');
    return padded.replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ');
  }

  void _decToBin() {
    final text = _decCtrl.text.trim();
    if (text.isEmpty) return;
    try {
      var val = int.parse(text);
      if (val < 0) val = (1 << _bitWidth) + val; // simple two's complement
      var bin = val.toRadixString(2);
      _binCtrl.text = _formatBinary(bin);
    } catch (_) {
      _binCtrl.text = 'Invalid';
    }
  }

  void _binToDec() {
    var text = _binCtrl.text.replaceAll(' ', '');
    if (text.isEmpty) return;
    try {
      final val = int.parse(text, radix: 2);
      _decCtrl.text = val.toString();
    } catch (_) {
      _decCtrl.text = 'Invalid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Decimal ↔ Binary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<int>(
              value: _bitWidth,
              items: const [
                DropdownMenuItem(value: 8, child: Text('8 bit')),
                DropdownMenuItem(value: 16, child: Text('16 bit')),
                DropdownMenuItem(value: 32, child: Text('32 bit')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _bitWidth = v);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _decCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Decimal (signed/unsigned)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _decToBin(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _binCtrl,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Binary (spaces every 4 bits allowed)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _binToDec(),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Float → Hex (IEEE 754)
// ────────────────────────────────────────────────
class FloatToHexScreen extends StatefulWidget {
  const FloatToHexScreen({super.key});

  @override
  State<FloatToHexScreen> createState() => _FloatToHexScreenState();
}

class _FloatToHexScreenState extends State<FloatToHexScreen> {
  final _floatCtrl = TextEditingController(text: '3.14159');
  String _result = '';
  int _precision = 32;
  Endian _endian = Endian.little;

  void _convert() {
    final val = double.tryParse(_floatCtrl.text);
    if (val == null) {
      setState(() => _result = 'Invalid input');
      return;
    }

    final bytes = _floatToBytes(val, _precision, _endian);
    final hex = bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join();

    setState(() {
      _result = '0x$hex';
    });
  }

  Uint8List _floatToBytes(double value, int bits, Endian endian) {
    final byteLength = bits ~/ 8;
    final buffer = Uint8List(byteLength);
    final view = ByteData.view(buffer.buffer);
    if (bits == 32) {
      view.setFloat32(0, value, endian);
    } else {
      view.setFloat64(0, value, endian);
    }
    return buffer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Float → Hex (IEEE 754)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _floatCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Float value',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _precision,
                    items: const [
                      DropdownMenuItem(value: 32, child: Text('Single (32-bit)')),
                      DropdownMenuItem(value: 64, child: Text('Double (64-bit)')),
                    ],
                    onChanged: (v) => setState(() => _precision = v!),
                    decoration: const InputDecoration(labelText: 'Precision'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<Endian>(
                    value: _endian,
                    items: const [
                      DropdownMenuItem(value: Endian.little, child: Text('Little Endian')),
                      DropdownMenuItem(value: Endian.big, child: Text('Big Endian')),
                    ],
                    onChanged: (v) => setState(() => _endian = v!),
                    decoration: const InputDecoration(labelText: 'Endianness'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _convert, child: const Text('Convert')),
            const SizedBox(height: 24),
            SelectableText(
              'Result: $_result',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Hex → Float (IEEE 754)
// ────────────────────────────────────────────────
class HexToFloatScreen extends StatefulWidget {
  const HexToFloatScreen({super.key});

  @override
  State<HexToFloatScreen> createState() => _HexToFloatScreenState();
}

class _HexToFloatScreenState extends State<HexToFloatScreen> {
  final _hexCtrl = TextEditingController(text: '40490FDB');
  String _result = '';
  int _precision = 32;
  Endian _endian = Endian.little;

  void _convert() {
    var hex = _hexCtrl.text.trim().replaceAll('0x', '').replaceAll(' ', '');
    if (hex.length != _precision ~/ 4) {
      setState(() => _result = 'Hex length mismatch (${_precision} bit = ${_precision~/4} chars)');
      return;
    }

    try {
      final bytes = Uint8List(hex.length ~/ 2);
      for (int i = 0; i < bytes.length; i++) {
        bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
      }

      final view = ByteData.view(bytes.buffer);
      final value = _precision == 32
          ? view.getFloat32(0, _endian)
          : view.getFloat64(0, _endian);

      setState(() {
        _result = value.toStringAsFixed(6);
      });
    } catch (e) {
      setState(() => _result = 'Invalid hex');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hex → Float (IEEE 754)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _hexCtrl,
              decoration: const InputDecoration(
                labelText: 'Hex (spaces allowed, 0x optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _precision,
                    items: const [
                      DropdownMenuItem(value: 32, child: Text('Single (32-bit)')),
                      DropdownMenuItem(value: 64, child: Text('Double (64-bit)')),
                    ],
                    onChanged: (v) => setState(() => _precision = v!),
                    decoration: const InputDecoration(labelText: 'Precision'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<Endian>(
                    value: _endian,
                    items: const [
                      DropdownMenuItem(value: Endian.little, child: Text('Little Endian')),
                      DropdownMenuItem(value: Endian.big, child: Text('Big Endian')),
                    ],
                    onChanged: (v) => setState(() => _endian = v!),
                    decoration: const InputDecoration(labelText: 'Endianness'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _convert, child: const Text('Convert')),
            const SizedBox(height: 24),
            SelectableText(
              'Result: $_result',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Binary ↔ Hex (Live)
// ────────────────────────────────────────────────
class BinaryHexScreen extends StatefulWidget {
  const BinaryHexScreen({super.key});

  @override
  State<BinaryHexScreen> createState() => _BinaryHexScreenState();
}

class _BinaryHexScreenState extends State<BinaryHexScreen> {
  final _binCtrl = TextEditingController();
  final _hexCtrl = TextEditingController();

  void _binToHex() {
    String bin = _binCtrl.text.trim().replaceAll(RegExp(r'[^01\s]'), '');
    if (bin.isEmpty) {
      _hexCtrl.clear();
      return;
    }

    try {
      String cleanBin = bin.replaceAll(' ', '');
      while (cleanBin.length % 4 != 0) {
        cleanBin = '0$cleanBin';
      }
      final hex = int.parse(cleanBin, radix: 2)
          .toRadixString(16)
          .toUpperCase()
          .padLeft((cleanBin.length / 4).ceil(), '0');

      _hexCtrl.text = '0x$hex';
      _hexCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _hexCtrl.text.length),
      );
    } catch (_) {
      _hexCtrl.text = 'Invalid binary';
    }
  }

  void _hexToBin() {
    String hex = _hexCtrl.text.trim().replaceAll('0x', '').replaceAll(' ', '').toUpperCase();
    if (hex.isEmpty) {
      _binCtrl.clear();
      return;
    }

    try {
      final intVal = int.parse(hex, radix: 16);
      var bin = intVal.toRadixString(2);
      final targetBits = (hex.length * 4).clamp(8, 64);
      bin = bin.padLeft(targetBits, '0');
      final formatted = bin.replaceAllMapped(RegExp(r'.{4}'), (m) => '${m.group(0)} ');
      _binCtrl.text = formatted.trimRight();
      _binCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _binCtrl.text.length),
      );
    } catch (_) {
      _binCtrl.text = 'Invalid hex';
    }
  }

  void _clearAll() {
    _binCtrl.clear();
    _hexCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Binary ↔ Hex')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _binCtrl,
              keyboardType: TextInputType.text,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Binary (0-1 & spaces allowed)',
                border: OutlineInputBorder(),
                helperText: 'Example: 1010 1100',
              ),
              onChanged: (_) => _binToHex(),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _hexCtrl,
              keyboardType: TextInputType.text,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Hex (0x optional, spaces allowed)',
                border: OutlineInputBorder(),
                helperText: 'Example: 0xAC or AC',
              ),
              onChanged: (_) => _hexToBin(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _clearAll,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// ASCII ↔ Hex (Live)
// ────────────────────────────────────────────────
class AsciiHexScreen extends StatefulWidget {
  const AsciiHexScreen({super.key});

  @override
  State<AsciiHexScreen> createState() => _AsciiHexScreenState();
}

class _AsciiHexScreenState extends State<AsciiHexScreen> {
  final _asciiCtrl = TextEditingController();
  final _hexCtrl = TextEditingController();

  void _asciiToHex() {
    final text = _asciiCtrl.text;
    if (text.isEmpty) {
      _hexCtrl.clear();
      return;
    }

    final bytes = utf8.encode(text);
    final hex = bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');

    _hexCtrl.text = hex;
    _hexCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _hexCtrl.text.length),
    );
  }

  void _hexToAscii() {
    String hex = _hexCtrl.text.trim().replaceAll(' ', '').toUpperCase();
    if (hex.isEmpty || hex.length % 2 != 0) {
      _asciiCtrl.text = hex.isEmpty ? '' : 'Invalid hex length';
      return;
    }

    try {
      final bytes = <int>[];
      for (int i = 0; i < hex.length; i += 2) {
        bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
      }
      final ascii = utf8.decode(bytes, allowMalformed: true);
      _asciiCtrl.text = ascii;
      _asciiCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _asciiCtrl.text.length),
      );
    } catch (_) {
      _asciiCtrl.text = 'Invalid hex';
    }
  }

  void _clearAll() {
    _asciiCtrl.clear();
    _hexCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ASCII ↔ Hex')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _asciiCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'ASCII / Text',
                border: OutlineInputBorder(),
                helperText: 'Type text → auto converts to hex',
              ),
              onChanged: (_) => _asciiToHex(),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _hexCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Hex (spaces between bytes allowed)',
                border: OutlineInputBorder(),
                helperText: 'Example: 48 65 6C 6C 6F → Hello',
              ),
              onChanged: (_) => _hexToAscii(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _clearAll,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Calculator (dengan desimal dan backspace)
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '0';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '0';
      } else if (value == '←') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '=') {
        try {
          final double calcResult = _evaluateExpression(_expression);
          _result = _formatResult(calcResult);
        } catch (e) {
          _result = 'Error';
        }
      } else {
        // Cegah multiple titik desimal di satu angka
        if (value == '.' && _expression.isNotEmpty) {
          final lastNumber = _expression.split(RegExp(r'[+\-*/]')).last;
          if (lastNumber.contains('.')) return;
        }
        _expression += value;
      }
    });
  }

  double _evaluateExpression(String expr) {
    // Evaluasi sederhana tanpa package (support +, -, *, /)
    List<String> tokens = expr.replaceAll(' ', '').split(RegExp(r'(?=[+\-*/])|(?<=[+\-*/])'));
    if (tokens.isEmpty) return 0;

    double num1 = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      String op = tokens[i];
      double num2 = double.parse(tokens[i + 1]);

      if (op == '+') num1 += num2;
      if (op == '-') num1 -= num2;
      if (op == '*') num1 *= num2;
      if (op == '/') {
        if (num2 == 0) throw Exception('Division by zero');
        num1 /= num2;
      }
    }
    return num1;
  }

  String _formatResult(double value) {
    // Hilangkan .0000 jika integer, maksimal 6 desimal
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  Widget _buildButton(String text, {Color? bgColor, Color textColor = Colors.white}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor ?? Colors.blueGrey[800],
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(20),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: Column(
        children: [
          // Display area
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: TextStyle(fontSize: 32, color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _result,
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Button grid
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildButton('C', bgColor: Colors.red, textColor: Colors.white),
                    _buildButton('←', bgColor: Colors.orange, textColor: Colors.white),
                    _buildButton('/', bgColor: Colors.orange[700]),
                    _buildButton('*', bgColor: Colors.orange[700]),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('7'),
                    _buildButton('8'),
                    _buildButton('9'),
                    _buildButton('-', bgColor: Colors.orange[700]),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('4'),
                    _buildButton('5'),
                    _buildButton('6'),
                    _buildButton('+', bgColor: Colors.orange[700]),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('1'),
                    _buildButton('2'),
                    _buildButton('3'),
                    _buildButton('=',
                        bgColor: Colors.orange,
                        textColor: Colors.white),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('0', bgColor: Colors.blueGrey[900]),
                    _buildButton('.'),
                    Expanded(child: SizedBox.shrink()), // spacer
                    Expanded(child: SizedBox.shrink()), // spacer
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
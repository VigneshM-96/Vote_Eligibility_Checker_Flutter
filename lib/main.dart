import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

void main() {
  runApp(const MyApp());
}

/* ===================== APP ===================== */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const EncryptionHomePage(),
    );
  }
}

/* ===================== MATRIX BACKGROUND ===================== */

class MatrixBackground extends StatefulWidget {
  final bool enabled;

  const MatrixBackground({super.key, required this.enabled});

  @override
  State<MatrixBackground> createState() => _MatrixBackgroundState();
}

class _MatrixBackgroundState extends State<MatrixBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final random = Random();
  late List<double> y;

  @override
  void initState() {
    super.initState();
    y = List.generate(80, (_) => random.nextDouble() * 800);
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        painter: MatrixPainter(y),
        size: MediaQuery.of(context).size,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class MatrixPainter extends CustomPainter {
  final List<double> y;
  final random = Random();
  final chars = '01ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  MatrixPainter(this.y);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < y.length; i++) {
      y[i] += 2;
      if (y[i] > size.height) y[i] = 0;

      final tp = TextPainter(
        text: TextSpan(
          text: chars[random.nextInt(chars.length)],
          style: TextStyle(
            color: const Color(0xFF00FF9C).withOpacity(0.25),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(i * 15.0, y[i]));
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

/* ===================== TYPING TEXT ===================== */

class TypingText extends StatefulWidget {
  final String text;
  final Color color;

  const TypingText(this.text, {super.key, required this.color});

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  String visible = '';
  int index = 0;

  @override
  void initState() {
    super.initState();
    _type();
  }

  void _type() async {
    while (index < widget.text.length) {
      await Future.delayed(const Duration(milliseconds: 18));
      if (!mounted) return;
      setState(() => visible += widget.text[index++]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectableText(visible, style: TextStyle(color: widget.color));
  }
}

/* ===================== AES FLOW ===================== */

class AESFlow extends StatelessWidget {
  final bool encrypt;
  const AESFlow({super.key, required this.encrypt});

  Widget box(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF00FF9C)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(t,
            style: const TextStyle(color: Color(0xFF00FF9C))),
      );

  @override
  Widget build(BuildContext context) {
    final steps = encrypt
        ? ['PLAINTEXT', 'SubBytes', 'ShiftRows', 'MixColumns', 'AddRoundKey', 'CIPHERTEXT']
        : ['CIPHERTEXT', 'InvShiftRows', 'InvSubBytes', 'AddRoundKey', 'InvMixColumns', 'PLAINTEXT'];

    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          encrypt ? 'ENCRYPTION FLOW' : 'DECRYPTION FLOW',
          style: const TextStyle(color: Colors.cyanAccent),
        ),
        const SizedBox(height: 12),
        ...steps.expand((s) => [
              box(s),
              const Icon(Icons.arrow_downward,
                  color: Color(0xFF00FF9C)),
              const SizedBox(height: 6),
            ]),
        const SizedBox(height: 40),
      ],
    );
  }
}

/* ===================== MAIN PAGE ===================== */

class EncryptionHomePage extends StatefulWidget {
  const EncryptionHomePage({super.key});

  @override
  State<EncryptionHomePage> createState() => _EncryptionHomePageState();
}

class _EncryptionHomePageState extends State<EncryptionHomePage> {
  final controller = TextEditingController();
  String encrypted = '';
  String decrypted = '';

  bool matrixOn = true;
  bool showEncryptFlow = false;
  bool showDecryptFlow = false;

  final key = encrypt.Key.fromUtf8('12345678901234567890123456789012');
  final iv = encrypt.IV.fromUtf8('1234567890123456');
  late encrypt.Encrypter encrypter;

  @override
  void initState() {
    super.initState();
    encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
  }

  void encryptText() {
    final e = encrypter.encrypt(controller.text, iv: iv);
    setState(() {
      encrypted = e.base64;
      decrypted = '';
      showEncryptFlow = true;
      showDecryptFlow = false;
    });
  }

  void decryptText() {
    final d = encrypter.decrypt(
      encrypt.Encrypted.fromBase64(encrypted),
      iv: iv,
    );
    setState(() {
      decrypted = d;
      showEncryptFlow = false;
      showDecryptFlow = true;
    });
  }

  void clearAll() {
    setState(() {
      controller.clear();
      encrypted = '';
      decrypted = '';
      showEncryptFlow = false;
      showDecryptFlow = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 AES Cyber Lab'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(matrixOn ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => matrixOn = !matrixOn),
          ),
        ],
      ),
      body: Stack(
        children: [
          MatrixBackground(enabled: matrixOn),
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                radius: 1.2,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60), // 👈 space ABOVE card
                  _card(context),
                  if (showEncryptFlow) const AESFlow(encrypt: true),
                  if (showDecryptFlow) const AESFlow(encrypt: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PLAINTEXT INPUT',
                  style: TextStyle(color: Colors.cyanAccent)),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.black54,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(onPressed: encryptText, child: const Text('ENCRYPT')),
                  const SizedBox(width: 10),
                  ElevatedButton(onPressed: decryptText, child: const Text('DECRYPT')),
                  const SizedBox(width: 10),
                  OutlinedButton(onPressed: clearAll, child: const Text('CLEAR')),
                ],
              ),
              const SizedBox(height: 12),
              if (encrypted.isNotEmpty) ...[
                const Text('ENCRYPTED OUTPUT'),
                TypingText(encrypted, color: Colors.grey),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: encrypted));
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Copied')));
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
              ],
              if (decrypted.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text('DECRYPTED OUTPUT'),
                TypingText(decrypted, color: Colors.greenAccent),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
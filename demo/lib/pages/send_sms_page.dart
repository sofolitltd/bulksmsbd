import 'package:flutter/material.dart';
import 'package:bulksmsbd/bulksmsbd.dart';
import '../widgets/log_view.dart';

class SendSmsPage extends StatefulWidget {
  final BulkSmsBd client;
  const SendSmsPage({super.key, required this.client});

  @override
  State<SendSmsPage> createState() => _SendSmsPageState();
}

class _SendSmsPageState extends State<SendSmsPage> {
  final _numbersCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _logCtrl = LogViewController();
  bool _isLoading = false;

  @override
  void dispose() {
    _numbersCtrl.dispose();
    _messageCtrl.dispose();
    _logCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final numbers = _numbersCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (numbers.isEmpty) {
      _logCtrl.log('Error: enter at least one number');
      return;
    }
    final msg = _messageCtrl.text.trim();
    if (msg.isEmpty) {
      _logCtrl.log('Error: enter a message');
      return;
    }
    setState(() => _isLoading = true);
    _logCtrl.log('Sending to ${numbers.length} number(s)...');
    final res = await widget.client.sendSms(numbers: numbers, message: msg);
    _logCtrl.log('${res.successCode}: ${res.message}');
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send SMS')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _numbersCtrl,
              decoration: const InputDecoration(
                labelText: 'Numbers (comma-separated)',
                border: OutlineInputBorder(),
                hintText: '88017XXXXXXXX,88018XXXXXXXX',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageCtrl,
              decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isLoading ? null : _send,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: const Text('Send SMS'),
            ),
            const SizedBox(height: 16),
            Expanded(child: LogView(controller: _logCtrl)),
          ],
        ),
      ),
    );
  }
}

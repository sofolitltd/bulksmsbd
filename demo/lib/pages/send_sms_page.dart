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
  final _messageCtrl = TextEditingController();
  final _logCtrl = LogViewController();
  final _numbers = <String>[];
  bool _isLoading = false;

  // Moved to the class level to preserve it during the sheet's closing animation
  final _recipientCtrl = TextEditingController();

  @override
  void dispose() {
    _messageCtrl.dispose();
    _logCtrl.dispose();
    _recipientCtrl.dispose(); // Safely disposed here
    super.dispose();
  }

  void _add(String number) {
    setState(() => _numbers.add(number));
    _logCtrl.log('Added: $number');
  }

  Future<void> _showAddSheet() async {
    // Clear previous input text before showing the modal sheet
    _recipientCtrl.clear();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Recipient', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _recipientCtrl,
                decoration: const InputDecoration(
                  labelText: 'Number',
                  hintText: '88017XXXXXXXX',
                ),
                keyboardType: TextInputType.phone,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (v) {
                  final num = v.trim();
                  if (num.isNotEmpty) {
                    Navigator.pop(ctx);
                    WidgetsBinding.instance.addPostFrameCallback((_) => _add(num));
                  }
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  final num = _recipientCtrl.text.trim();
                  if (num.isNotEmpty) {
                    Navigator.pop(ctx);
                    WidgetsBinding.instance.addPostFrameCallback((_) => _add(num));
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _send() async {
    if (_numbers.isEmpty) {
      _logCtrl.log('Error: add at least one recipient');
      return;
    }
    final msg = _messageCtrl.text.trim();
    if (msg.isEmpty) {
      _logCtrl.log('Error: enter a message');
      return;
    }
    setState(() => _isLoading = true);
    _logCtrl.log('Sending to ${_numbers.length} number(s)...');
    final res = await widget.client.sendSms(numbers: _numbers, message: msg);
    _logCtrl.log('${res.successCode}: ${res.message}');
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Send SMS')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: cs.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(Icons.people_rounded, size: 12, color: cs.secondary),
                        ),
                        const SizedBox(width: 12),
                        Text('Recipients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_numbers.isNotEmpty)
                      Column(
                        children: [
                          ..._numbers.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(Icons.person_rounded, size: 16, color: cs.secondary),
                                const SizedBox(width: 8),
                                Expanded(child: Text(e.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                                  color: const Color(0xFFEF4444),
                                  onPressed: () => setState(() => _numbers.removeAt(e.key)),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          )),
                          const SizedBox(height: 8),
                        ],
                      ),
                    FilledButton.icon(
                      onPressed: _showAddSheet,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('New Recipient'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.message_rounded, size: 12, color: Color(0xFF8B5CF6)),
                        ),
                        const SizedBox(width: 12),
                        Text('Message', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _messageCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: (_numbers.isEmpty || _isLoading) ? null : _send,
              icon: _isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, size: 20),
              label: Text(_isLoading ? 'Sending...' : 'Send SMS'),
            ),
            const SizedBox(height: 16),
            Text('Log', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
            const SizedBox(height: 6),
            Expanded(child: LogView(controller: _logCtrl)),
          ],
        ),
      ),
    );
  }
}
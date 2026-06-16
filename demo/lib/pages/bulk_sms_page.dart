
import 'package:flutter/material.dart';
import 'package:bulksmsbd/bulksmsbd.dart';
import '../widgets/log_view.dart';

class BulkSmsPage extends StatefulWidget {
  final BulkSmsBd client;
  const BulkSmsPage({super.key, required this.client});

  @override
  State<BulkSmsPage> createState() => _BulkSmsPageState();
}

class _BulkSmsPageState extends State<BulkSmsPage> {
  final _logCtrl = LogViewController();
  final _items = <BulkSmsBulkItem>[];
  bool _isLoading = false;

  // Declaring controllers here keeps them alive during the sheet's closing animation
  final _numberCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _logCtrl.dispose();
    _numberCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _add(String number, String message) {
    setState(() {
      _items.add(BulkSmsBulkItem(to: number, message: message));
    });
    _logCtrl.log('Added: $number');
  }

  Future<void> _showAddSheet() async {
    // Clear previous inputs before opening the sheet
    _numberCtrl.clear();
    _msgCtrl.clear();

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
                controller: _numberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Number',
                  hintText: '88017XXXXXXXX',
                ),
                keyboardType: TextInputType.phone,
                autofocus: true,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _msgCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Type message...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  final num = _numberCtrl.text.trim();
                  final msg = _msgCtrl.text.trim();
                  if (num.isNotEmpty && msg.isNotEmpty) {
                    Navigator.pop(ctx);
                    WidgetsBinding.instance.addPostFrameCallback((_) => _add(num, msg));
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
    if (_items.isEmpty) {
      _logCtrl.log('Error: add at least one recipient');
      return;
    }
    setState(() => _isLoading = true);
    _logCtrl.log('Sending ${_items.length} messages...');
    final res = await widget.client.sendBulkSms(messages: _items);
    _logCtrl.log('${res.successCode}: ${res.message}');
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk SMS')),
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
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.dynamic_feed_rounded, size: 12, color: Color(0xFFF59E0B)),
                        ),
                        const SizedBox(width: 12),
                        Text('Add Recipients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
                      ],
                    ),
                    const SizedBox(height: 20),
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
            if (_items.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
                        child: Row(
                          children: [
                            Text('Recipients', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('${_items.length}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.primary)),
                            ),
                          ],
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 140),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: _items.asMap().entries.map((e) => ListTile(
                            dense: true,
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(child: Text('${e.key + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.primary))),
                            ),
                            title: Text(e.value.to, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            subtitle: Text(e.value.message, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                              color: const Color(0xFFEF4444),
                              onPressed: () => setState(() => _items.removeAt(e.key)),
                            ),
                            visualDensity: VisualDensity.compact,
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_items.isNotEmpty) const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: (_items.isEmpty || _isLoading) ? null : _send,
              icon: _isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.dynamic_feed_rounded, size: 20),
              label: Text(_isLoading ? 'Sending...' : 'Send Bulk SMS'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Log', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                GestureDetector(
                  onTap: () => _logCtrl.clear(),
                  child: Text('Clear', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cs.primary)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(child: LogView(controller: _logCtrl)),
          ],
        ),
      ),
    );
  }
}


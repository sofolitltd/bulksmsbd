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
  final _toCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  final _logCtrl = LogViewController();
  final _items = <BulkSmsBulkItem>[];
  bool _isLoading = false;

  @override
  void dispose() {
    _toCtrl.dispose();
    _msgCtrl.dispose();
    _logCtrl.dispose();
    super.dispose();
  }

  void _add() {
    final to = _toCtrl.text.trim();
    final msg = _msgCtrl.text.trim();
    if (to.isEmpty || msg.isEmpty) return;
    setState(() {
      _items.add(BulkSmsBulkItem(to: to, message: msg));
      _toCtrl.clear();
      _msgCtrl.clear();
    });
    _logCtrl.log('Added: $to');
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk SMS')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(child: TextField(
                controller: _toCtrl,
                decoration: const InputDecoration(labelText: 'Number', border: OutlineInputBorder()),
              )),
              const SizedBox(width: 8),
              Expanded(child: TextField(
                controller: _msgCtrl,
                decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
              )),
              const SizedBox(width: 8),
              IconButton.filled(onPressed: _add, icon: const Icon(Icons.add)),
            ]),
            const SizedBox(height: 8),
            if (_items.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 140),
                decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.outline), borderRadius: BorderRadius.circular(8)),
                child: ListView(
                  children: _items.asMap().entries.map((e) => ListTile(
                    dense: true,
                    title: Text(e.value.to),
                    subtitle: Text(e.value.message, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => setState(() => _items.removeAt(e.key)),
                    ),
                  )).toList(),
                ),
              ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: (_items.isEmpty || _isLoading) ? null : _send,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.dynamic_feed),
              label: const Text('Send Bulk SMS'),
            ),
            const SizedBox(height: 16),
            Expanded(child: LogView(controller: _logCtrl)),
          ],
        ),
      ),
    );
  }
}

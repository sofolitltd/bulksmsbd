import 'package:flutter/material.dart';
import 'package:bulksmsbd/bulksmsbd.dart';

void main() {
  runApp(const BulkSmsBdDemoApp());
}

class BulkSmsBdDemoApp extends StatelessWidget {
  const BulkSmsBdDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BulkSMS BD Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const BulkSmsBdPage(),
    );
  }
}

class BulkSmsBdPage extends StatefulWidget {
  const BulkSmsBdPage({super.key});

  @override
  State<BulkSmsBdPage> createState() => _BulkSmsBdPageState();
}

class _BulkSmsBdPageState extends State<BulkSmsBdPage> {
  final _apiKeyCtrl = TextEditingController();
  final _senderIdCtrl = TextEditingController();
  final _numbersCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _otpNumberCtrl = TextEditingController();
  final _otpBrandCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _bulkToCtrl = TextEditingController();
  final _bulkMsgCtrl = TextEditingController();
  final _logCtrl = TextEditingController();
  final _bulkItems = <BulkSmsBulkItem>[];

  BulkSmsBd? _client;
  bool _loading = false;

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _senderIdCtrl.dispose();
    _numbersCtrl.dispose();
    _messageCtrl.dispose();
    _otpNumberCtrl.dispose();
    _otpBrandCtrl.dispose();
    _otpCtrl.dispose();
    _bulkToCtrl.dispose();
    _bulkMsgCtrl.dispose();
    _logCtrl.dispose();
    _client?.close();
    super.dispose();
  }

  void _initClient() {
    _client?.close();
    _client = BulkSmsBd(
      apiKey: _apiKeyCtrl.text.trim(),
      senderId: _senderIdCtrl.text.trim(),
    );
  }

  void _log(String text) {
    _logCtrl.text = '${_logCtrl.text}[${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}] $text\n';
  }

  Future<void> _checkBalance() async {
    if (_client == null) { _initClient(); }
    setState(() => _loading = true);
    final bal = await _client!.getBalance();
    _log('Balance: $bal BDT');
    setState(() => _loading = false);
  }

  Future<void> _sendSms() async {
    if (_client == null) { _initClient(); }
    setState(() => _loading = true);
    final numbers = _numbersCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (numbers.isEmpty) { _log('Error: enter at least one number'); setState(() => _loading = false); return; }
    final res = await _client!.sendSms(numbers: numbers, message: _messageCtrl.text.trim());
    _log('SMS → ${res.successCode}: ${res.message}');
    setState(() => _loading = false);
  }

  Future<void> _sendOtp() async {
    if (_client == null) { _initClient(); }
    setState(() => _loading = true);
    final res = await _client!.sendOtp(
      number: _otpNumberCtrl.text.trim(),
      brandName: _otpBrandCtrl.text.trim(),
      otp: _otpCtrl.text.trim(),
    );
    _log('OTP → ${res.successCode}: ${res.message}');
    setState(() => _loading = false);
  }

  void _addBulkItem() {
    final to = _bulkToCtrl.text.trim();
    final msg = _bulkMsgCtrl.text.trim();
    if (to.isEmpty || msg.isEmpty) return;
    setState(() {
      _bulkItems.add(BulkSmsBulkItem(to: to, message: msg));
      _bulkToCtrl.clear();
      _bulkMsgCtrl.clear();
    });
  }

  Future<void> _sendBulk() async {
    if (_client == null) { _initClient(); }
    if (_bulkItems.isEmpty) { _log('Error: add at least one bulk item'); return; }
    setState(() => _loading = true);
    final res = await _client!.sendBulkSms(messages: List.from(_bulkItems));
    _log('Bulk → ${res.successCode}: ${res.message}');
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('BulkSMS BD Demo'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _section('Credentials', [
                    TextField(controller: _apiKeyCtrl, decoration: const InputDecoration(labelText: 'API Key', border: OutlineInputBorder()), obscureText: true),
                    const SizedBox(height: 8),
                    TextField(controller: _senderIdCtrl, decoration: const InputDecoration(labelText: 'Sender ID', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    FilledButton(onPressed: () { _initClient(); _log('Client initialized'); }, child: const Text('Apply Credentials')),
                  ]),
                  const SizedBox(height: 12),
                  _section('Balance', [
                    FilledButton.icon(onPressed: _checkBalance, icon: const Icon(Icons.account_balance_wallet_outlined), label: const Text('Check Balance')),
                  ]),
                  const SizedBox(height: 12),
                  _section('Send SMS', [
                    TextField(controller: _numbersCtrl, decoration: const InputDecoration(labelText: 'Numbers (comma-separated)', border: OutlineInputBorder(), hintText: '88017XXXXXXXX,88018XXXXXXXX')),
                    const SizedBox(height: 8),
                    TextField(controller: _messageCtrl, decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()), maxLines: 2),
                    const SizedBox(height: 8),
                    FilledButton.icon(onPressed: _sendSms, icon: const Icon(Icons.send), label: const Text('Send SMS')),
                  ]),
                  const SizedBox(height: 12),
                  _section('Send OTP', [
                    TextField(controller: _otpNumberCtrl, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: TextField(controller: _otpBrandCtrl, decoration: const InputDecoration(labelText: 'Brand Name', border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _otpCtrl, decoration: const InputDecoration(labelText: 'OTP Code', border: OutlineInputBorder()))),
                    ]),
                    const SizedBox(height: 8),
                    FilledButton.icon(onPressed: _sendOtp, icon: const Icon(Icons.sms_failed_outlined), label: const Text('Send OTP')),
                  ]),
                  const SizedBox(height: 12),
                  _section('Bulk SMS', [
                    Row(children: [
                      Expanded(child: TextField(controller: _bulkToCtrl, decoration: const InputDecoration(labelText: 'Number', border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _bulkMsgCtrl, decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      IconButton.filled(onPressed: _addBulkItem, icon: const Icon(Icons.add)),
                    ]),
                    if (_bulkItems.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.outline), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: _bulkItems.asMap().entries.map((e) => ListTile(
                            dense: true,
                            title: Text(e.value.to),
                            subtitle: Text(e.value.message, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => setState(() => _bulkItems.removeAt(e.key))),
                          )).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    FilledButton.icon(onPressed: _bulkItems.isEmpty ? null : _sendBulk, icon: const Icon(Icons.dynamic_feed), label: const Text('Send Bulk SMS')),
                  ]),
                  const SizedBox(height: 12),
                  _section('Log', [
                    TextField(
                      controller: _logCtrl,
                      readOnly: true,
                      maxLines: 8,
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Responses appear here...'),
                    ),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:bulksmsbd/bulksmsbd.dart';
import '../widgets/log_view.dart';

class BalancePage extends StatefulWidget {
  final BulkSmsBd client;
  const BalancePage({super.key, required this.client});

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  final _logCtrl = LogViewController();
  bool _isLoading = false;

  @override
  void dispose() {
    _logCtrl.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    setState(() => _isLoading = true);
    _logCtrl.log('Checking balance...');
    final bal = await widget.client.getBalance();
    _logCtrl.log('Balance: $bal BDT');
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check Balance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: _isLoading ? null : _check,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('Check Balance'),
            ),
            const SizedBox(height: 16),
            Expanded(child: LogView(controller: _logCtrl)),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
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
  String? _result;

  @override
  void dispose() {
    _logCtrl.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    setState(() => _isLoading = true);
    _logCtrl.log('Checking balance...');
    final bal = await widget.client.getBalance();
    _result = bal;
    _logCtrl.log('Balance: $bal BDT');
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Check Balance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.primary.withValues(alpha: 0.15), cs.primary.withValues(alpha: 0.05)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.account_balance_wallet_rounded, size: 24, color: cs.primary),
                        ),
                        const SizedBox(width: 14),
                        FilledButton.icon(
                          onPressed: _isLoading ? null : _check,
                          icon: _isLoading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.refresh_rounded, size: 20),
                          label: Text(_isLoading ? 'Checking...' : 'Check Balance'),
                        ),
                      ],
                    ),
                    if (_result != null && !_result!.startsWith('Error:')) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.monetization_on_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Balance: $_result BDT',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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

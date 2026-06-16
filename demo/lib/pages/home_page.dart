import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bulksmsbd/bulksmsbd.dart';
import 'balance_page.dart';
import 'send_sms_page.dart';
import 'send_otp_page.dart';
import 'bulk_sms_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final BulkSmsBd _client;

  @override
  void initState() {
    super.initState();
    final apiKey = dotenv.env['API_KEY'] ?? '';
    final senderId = dotenv.env['SENDER_ID'] ?? '';
    if (apiKey.isEmpty || senderId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Configuration Missing'),
            content: const Text(
              'API_KEY and SENDER_ID must be set in the .env file.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
    _client = BulkSmsBd(apiKey: apiKey, senderId: senderId);
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  void _navigate(WidgetBuilder builder) {
    Navigator.push(context, MaterialPageRoute(builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('BulkSMS BD Demo'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Features', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _FeatureButton(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Check Balance',
            onTap: () => _navigate((_) => BalancePage(client: _client)),
          ),
          _FeatureButton(
            icon: Icons.send,
            label: 'Send SMS',
            onTap: () => _navigate((_) => SendSmsPage(client: _client)),
          ),
          _FeatureButton(
            icon: Icons.sms_failed_outlined,
            label: 'Send OTP',
            onTap: () => _navigate((_) => SendOtpPage(client: _client)),
          ),
          _FeatureButton(
            icon: Icons.dynamic_feed,
            label: 'Bulk SMS',
            onTap: () => _navigate((_) => BulkSmsPage(client: _client)),
          ),
        ],
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

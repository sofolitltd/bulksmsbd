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
            content: const Text('API_KEY and SENDER_ID must be set in the .env file.'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('BulkSMS BD')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                'Features',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _FeatureCard(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Check Balance',
                    subtitle: 'View remaining SMS credits',
                    color: const Color(0xFF6366F1),
                    onTap: () => _navigate((_) => BalancePage(client: _client)),
                  ),
                  const SizedBox(height: 10),
                  _FeatureCard(
                    icon: Icons.send_rounded,
                    label: 'Send SMS',
                    subtitle: 'Message one or more numbers',
                    color: const Color(0xFF8B5CF6),
                    onTap: () => _navigate((_) => SendSmsPage(client: _client)),
                  ),
                  const SizedBox(height: 10),
                  _FeatureCard(
                    icon: Icons.sms_failed_rounded,
                    label: 'Send OTP',
                    subtitle: 'Send a branded one-time password',
                    color: const Color(0xFF06B6D4),
                    onTap: () => _navigate((_) => SendOtpPage(client: _client)),
                  ),
                  const SizedBox(height: 10),
                  _FeatureCard(
                    icon: Icons.dynamic_feed_rounded,
                    label: 'Bulk SMS',
                    subtitle: 'Different messages to different numbers',
                    color: const Color(0xFFF59E0B),
                    onTap: () => _navigate((_) => BulkSmsPage(client: _client)),
                  ),
                  const SizedBox(height: 24),
                  
                  _DevInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: const Color(0xFFCBD5E1), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _DevInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: Color(0xFFE2E8F0), height: 1),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          
            const Text(
              'Developed by ',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
            Text(
              'Sofol IT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'bulksmsbd v1.0.1',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

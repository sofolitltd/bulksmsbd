import 'package:flutter/material.dart';
import 'package:bulksmsbd/bulksmsbd.dart';
import '../widgets/log_view.dart';

class SendOtpPage extends StatefulWidget {
  final BulkSmsBd client;
  const SendOtpPage({super.key, required this.client});

  @override
  State<SendOtpPage> createState() => _SendOtpPageState();
}

class _SendOtpPageState extends State<SendOtpPage> {
  final _numberCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _logCtrl = LogViewController();
  bool _isLoading = false;

  @override
  void dispose() {
    _numberCtrl.dispose();
    _brandCtrl.dispose();
    _otpCtrl.dispose();
    _logCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final number = _numberCtrl.text.trim();
    final brand = _brandCtrl.text.trim();
    final otp = _otpCtrl.text.trim();
    if (number.isEmpty || brand.isEmpty || otp.isEmpty) {
      _logCtrl.log('Error: fill all fields');
      return;
    }
    setState(() => _isLoading = true);
    _logCtrl.log('Sending OTP to $number...');
    final res = await widget.client.sendOtp(number: number, brandName: brand, otp: otp);
    _logCtrl.log('${res.successCode}: ${res.message}');
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Send OTP')),
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
                            color: cs.tertiary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(Icons.sms_failed_rounded, size: 12, color: cs.tertiary),
                        ),
                        const SizedBox(width: 12),
                        Text('Compose OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _numberCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '88017XXXXXXXX',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _brandCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Brand Name',
                              hintText: 'YourApp',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _otpCtrl,
                            decoration: const InputDecoration(
                              labelText: 'OTP Code',
                              hintText: '123456',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _send,
                      icon: _isLoading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.sms_failed_rounded, size: 20),
                      label: Text(_isLoading ? 'Sending...' : 'Send OTP'),
                    ),
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

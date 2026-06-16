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
    return Scaffold(
      appBar: AppBar(title: const Text('Send OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _numberCtrl,
              decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(
                controller: _brandCtrl,
                decoration: const InputDecoration(labelText: 'Brand Name', border: OutlineInputBorder()),
              )),
              const SizedBox(width: 8),
              Expanded(child: TextField(
                controller: _otpCtrl,
                decoration: const InputDecoration(labelText: 'OTP Code', border: OutlineInputBorder()),
              )),
            ]),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isLoading ? null : _send,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.sms_failed_outlined),
              label: const Text('Send OTP'),
            ),
            const SizedBox(height: 16),
            Expanded(child: LogView(controller: _logCtrl)),
          ],
        ),
      ),
    );
  }
}

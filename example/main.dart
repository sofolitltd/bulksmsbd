import 'package:bulksmsbd/bulksmsbd.dart';

/// Example usage of the bulksmsbd package.
///
/// Replace the placeholder credentials with your own from
/// [bulksmsbd.net](https://bulksmsbd.net) before running.
Future<void> main() async {
  final smsClient = BulkSmsBd(
    apiKey: 'your_api_key',
    senderId: 'your_sender_id',
  );

  try {
    // Check account balance
    final balance = await smsClient.getBalance();
    print('Balance: $balance BDT');

    // Send SMS to one or more numbers
    final smsResponse = await smsClient.sendSms(
      numbers: ['88017XXXXXXXX', '88018XXXXXXXX'],
      message: 'Your message here',
    );
    print('Send SMS: ${smsResponse.message}');

    // Send an OTP
    final otpResponse = await smsClient.sendOtp(
      number: '88017XXXXXXXX',
      brandName: 'YourBrand',
      otp: '123456',
    );
    print('Send OTP: ${otpResponse.message}');

    // Send different messages to different numbers (bulk SMS)
    final bulkResponse = await smsClient.sendBulkSms(messages: [
      BulkSmsBulkItem(to: '88017XXXXXXXX', message: 'First message'),
      BulkSmsBulkItem(to: '88018XXXXXXXX', message: 'Second message'),
    ]);
    print('Bulk SMS: ${bulkResponse.message}');
  } on Exception catch (e) {
    print('Error: $e');
  } finally {
    smsClient.close();
  }
}

import 'package:bulksmsbd/bulksmsbd.dart';

void main() async {
  final smsClient = BulkSmsBd(
    apiKey: 'your_api_key',
    senderId: 'your_sender_id',
  );

  final balance = await smsClient.getBalance();
  print('Sofol IT Gateway Balance Check: $balance BDT');

  smsClient.close();
}

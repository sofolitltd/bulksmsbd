import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:bulksmsbd/bulksmsbd.dart';
import 'package:test/test.dart';

void main() {
  late BulkSmsBd client;

    setUp(() {
    final mockClient = MockClient((request) async {
      if (request.url.path.contains('smsapi') &&
          !request.url.path.contains('many')) {
        return http.Response(
          '{"response_code": 202, "success_message": "SMS submitted successfully"}',
          200,
        );
      }
      if (request.url.path.contains('smsapimany')) {
        return http.Response(
          '{"response_code": 202, "success_message": "SMS submitted successfully"}',
          200,
        );
      }
      if (request.url.path.contains('getBalanceApi')) {
        return http.Response(
          '{"response_code": 202, "balance": 5000}',
          200,
        );
      }
      return http.Response(
        '{"response_code": 1005, "error_message": "Internal error"}',
        200,
      );
    });

    client = BulkSmsBd(
      apiKey: 'test_key',
      senderId: 'test_sender',
      client: mockClient,
    );
  });

  tearDown(() {
    client.close();
  });

  group('sendSms', () {
    test('returns success on 202', () async {
      final res = await client.sendSms(
        numbers: ['8801711111111'],
        message: 'Hello',
      );
      expect(res.isSuccess, true);
      expect(res.successCode, '202');
      expect(res.message, 'SMS submitted successfully');
    });

    test('accepts multiple numbers', () async {
      final res = await client.sendSms(
        numbers: ['8801711111111', '8801811111111'],
        message: 'Broadcast',
      );
      expect(res.isSuccess, true);
    });

    test('catches exceptions gracefully', () async {
      final failingClient = BulkSmsBd(
        apiKey: 'x',
        senderId: 'x',
        client: MockClient((_) => throw Exception('Network error')),
      );
      final res = await failingClient.sendSms(
        numbers: ['8801711111111'],
        message: 'Test',
      );
      expect(res.isSuccess, false);
      expect(res.successCode, '1005');
      expect(res.message, contains('Exception'));
      failingClient.close();
    });
  });

  group('sendBulkSms', () {
    test('returns success on 202', () async {
      final res = await client.sendBulkSms(messages: [
        BulkSmsBulkItem(to: '8801711111111', message: 'Msg 1'),
        BulkSmsBulkItem(to: '8801811111111', message: 'Msg 2'),
      ]);
      expect(res.isSuccess, true);
      expect(res.successCode, '202');
    });
  });

  group('sendOtp', () {
    test('sends formatted OTP message', () async {
      final res = await client.sendOtp(
        number: '8801711111111',
        brandName: 'TestApp',
        otp: '123456',
      );
      expect(res.isSuccess, true);
    });
  });

  group('getBalance', () {
    test('returns balance string on success', () async {
      final balance = await client.getBalance();
      expect(balance, '5000');
    });

    test('returns 0.0 on failure', () async {
      final failingClient = BulkSmsBd(
        apiKey: 'x',
        senderId: 'x',
        client: MockClient((_) => Future.value(http.Response('{}', 500))),
      );
      final balance = await failingClient.getBalance();
      expect(balance, '0.0');
      failingClient.close();
    });
  });

  group('error code mapping', () {
    test('maps known error codes to messages', () {
      expect(
        BulkSmsResponse.getErrorMessage('1002'),
        contains('Sender ID not correct'),
      );
      expect(
        BulkSmsResponse.getErrorMessage('1007'),
        contains('Balance Insufficient'),
      );
      expect(
        BulkSmsResponse.getErrorMessage('9999'),
        contains('Unknown Error'),
      );
    });

    test('parses error response correctly', () async {
      final errorClient = BulkSmsBd(
        apiKey: 'x',
        senderId: 'x',
        client: MockClient((_) => Future.value(http.Response(
              '{"response_code": 1002, "error_message": "Sender ID not correct / sender ID is disabled"}',
              200,
            ))),
      );
      final res = await errorClient.sendSms(
        numbers: ['8801711111111'],
        message: 'Test',
      );
      expect(res.isSuccess, false);
      expect(res.successCode, '1002');
      expect(res.message, contains('Sender ID not correct'));
      errorClient.close();
    });
  });
}

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

    test('catches network exceptions gracefully', () async {
      final failingClient = BulkSmsBd(
        apiKey: 'x',
        senderId: 'x',
        client: MockClient((_) => throw Exception('Network error')),
      );
      addTearDown(failingClient.close);
      final res = await failingClient.sendSms(
        numbers: ['8801711111111'],
        message: 'Test',
      );
      expect(res.isSuccess, false);
      expect(res.successCode, '1005');
      expect(res.message, contains('Request failed'));
    });

    test('handles empty response body', () async {
      final emptyClient = BulkSmsBd(
        apiKey: 'x',
        senderId: 'x',
        client: MockClient((_) => Future.value(http.Response('', 200))),
      );
      addTearDown(emptyClient.close);
      final res = await emptyClient.sendSms(
        numbers: ['8801711111111'],
        message: 'Test',
      );
      expect(res.isSuccess, false);
      expect(res.message, contains('Empty response'));
    });

    test('handles malformed JSON', () async {
      final badJsonClient = BulkSmsBd(
        apiKey: 'x',
        senderId: 'x',
        client: MockClient((_) => Future.value(http.Response('not json', 200))),
      );
      addTearDown(badJsonClient.close);
      final res = await badJsonClient.sendSms(
        numbers: ['8801711111111'],
        message: 'Test',
      );
      expect(res.isSuccess, false);
      expect(res.message, contains('Invalid response format'));
    });

    test('handles non-200 HTTP status', () async {
      final errorClient = BulkSmsBd(
        apiKey: 'x',
        senderId: 'x',
        client: MockClient((_) => Future.value(http.Response('{}', 500))),
      );
      addTearDown(errorClient.close);
      final res = await errorClient.sendSms(
        numbers: ['8801711111111'],
        message: 'Test',
      );
      expect(res.isSuccess, false);
      expect(res.successCode, '1005');
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

    test('returns error string on HTTP failure', () async {
      final failingClient = BulkSmsBd(
        apiKey: 'x',
        senderId: 'x',
        client: MockClient((_) => Future.value(http.Response('{}', 500))),
      );
      addTearDown(failingClient.close);
      final balance = await failingClient.getBalance();
      expect(balance, startsWith('Error:'));
    });

    test('handles non-map response', () async {
      final badClient = BulkSmsBd(
        apiKey: 'x',
        senderId: 'x',
        client: MockClient((_) => Future.value(http.Response('"string"', 200))),
      );
      addTearDown(badClient.close);
      final balance = await badClient.getBalance();
      expect(balance, startsWith('Error:'));
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
      addTearDown(errorClient.close);
      final res = await errorClient.sendSms(
        numbers: ['8801711111111'],
        message: 'Test',
      );
      expect(res.isSuccess, false);
      expect(res.successCode, '1002');
      expect(res.message, contains('Sender ID not correct'));
    });

    test('uses fallback message when only response_code is present', () async {
      final minimalClient = BulkSmsBd(
        apiKey: 'x',
        senderId: 'x',
        client: MockClient((_) => Future.value(http.Response(
              '{"response_code": 1032}',
              200,
            ))),
      );
      addTearDown(minimalClient.close);
      final res = await minimalClient.sendSms(
        numbers: ['8801711111111'],
        message: 'Test',
      );
      expect(res.isSuccess, false);
      expect(res.successCode, '1032');
      expect(res.message, contains('IP Not whitelisted'));
    });
  });

  group('close', () {
    test('can be called multiple times without throwing', () {
      client.close();
      client.close();
    });
  });
}

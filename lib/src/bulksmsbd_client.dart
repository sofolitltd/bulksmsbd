import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class BulkSmsBd {
  final String apiKey;
  final String senderId;
  final http.Client _client;

  static const String _baseUrl = 'https://bulksmsbd.net/api';

  BulkSmsBd({
    required this.apiKey,
    required this.senderId,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<BulkSmsResponse> sendSms({
    required List<String> numbers,
    required String message,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/smsapi'),
        body: {
          'api_key': apiKey,
          'senderid': senderId,
          'number': numbers.join(','),
          'message': message,
        },
      );

      return BulkSmsResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return BulkSmsResponse(
        successCode: '1005',
        message: 'Exception: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

  Future<BulkSmsResponse> sendBulkSms({
    required List<BulkSmsBulkItem> messages,
  }) async {
    try {
      final List<Map<String, String>> mappedMessages =
          messages.map((item) => item.toJson()).toList();

      final response = await _client.post(
        Uri.parse('$_baseUrl/smsapimany'),
        body: {
          'api_key': apiKey,
          'senderid': senderId,
          'messages': jsonEncode(mappedMessages),
        },
      );

      return BulkSmsResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return BulkSmsResponse(
        successCode: '1005',
        message: 'Exception: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

  Future<BulkSmsResponse> sendOtp({
    required String number,
    required String brandName,
    required String otp,
  }) async {
    final String formattedMessage = 'Your $brandName OTP is $otp';
    return sendSms(numbers: [number], message: formattedMessage);
  }

  Future<String> getBalance() async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/getBalanceApi'),
        body: {'api_key': apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['balance']?.toString() ?? '0.0';
      }
      return '0.0';
    } catch (_) {
      return '0.0';
    }
  }

  void close() {
    _client.close();
  }
}

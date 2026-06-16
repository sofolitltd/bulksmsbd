import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class BulkSmsBd {
  final String apiKey;
  final String senderId;
  final http.Client _client;
  bool _isClosed = false;

  static const String _baseUrl = 'https://bulksmsbd.net/api';
  static const Duration _timeout = Duration(seconds: 30);

  BulkSmsBd({
    required this.apiKey,
    required this.senderId,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<BulkSmsResponse> _post(
    Uri uri,
    Map<String, String> body,
  ) async {
    try {
      final response = await _client.post(uri, body: body).timeout(_timeout);
      if (response.body.isEmpty) {
        return BulkSmsResponse(
          successCode: '1005',
          message: 'Empty response from server',
          isSuccess: false,
        );
      }
      return BulkSmsResponse.fromJson(jsonDecode(response.body));
    } on TimeoutException {
      return BulkSmsResponse(
        successCode: '1005',
        message: 'Request timed out',
        isSuccess: false,
      );
    } on FormatException catch (e) {
      return BulkSmsResponse(
        successCode: '1005',
        message: 'Invalid response format: ${e.message}',
        isSuccess: false,
      );
    } catch (e) {
      return BulkSmsResponse(
        successCode: '1005',
        message: 'Request failed: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

  Future<BulkSmsResponse> sendSms({
    required List<String> numbers,
    required String message,
  }) {
    return _post(
      Uri.parse('$_baseUrl/smsapi'),
      {
        'api_key': apiKey,
        'senderid': senderId,
        'number': numbers.join(','),
        'message': message,
      },
    );
  }

  Future<BulkSmsResponse> sendBulkSms({
    required List<BulkSmsBulkItem> messages,
  }) {
    final mappedMessages = messages.map((item) => item.toJson()).toList();
    return _post(
      Uri.parse('$_baseUrl/smsapimany'),
      {
        'api_key': apiKey,
        'senderid': senderId,
        'messages': jsonEncode(mappedMessages),
      },
    );
  }

  Future<BulkSmsResponse> sendOtp({
    required String number,
    required String brandName,
    required String otp,
  }) {
    final formattedMessage = 'Your $brandName OTP is $otp';
    return sendSms(numbers: [number], message: formattedMessage);
  }

  Future<String> getBalance() async {
    try {
      final response =
          await _client.post(
            Uri.parse('$_baseUrl/getBalanceApi'),
            body: {'api_key': apiKey},
          ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is! Map) return 'Error: invalid response format';
        return data['balance']?.toString() ?? '0.0';
      }
      return 'Error: request failed (HTTP ${response.statusCode})';
    } on TimeoutException {
      return 'Error: request timed out';
    } on FormatException {
      return 'Error: invalid response format';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  void close() {
    if (!_isClosed) {
      _isClosed = true;
      _client.close();
    }
  }
}

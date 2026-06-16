import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

/// Client for the [bulksmsbd.net](https://bulksmsbd.net) SMS gateway API.
///
/// Uses the provided [apiKey] and [senderId] for authentication.
/// All HTTP requests have a 30-second timeout.
///
/// ```dart
/// final client = BulkSmsBd(
///   apiKey: 'your_api_key',
///   senderId: 'your_sender_id',
/// );
///
/// final response = await client.sendSms(
///   numbers: ['88017XXXXXXXX'],
///   message: 'Hello',
/// );
/// print(response.message);
///
/// client.close();
/// ```
class BulkSmsBd {
  /// API key from your bulksmsbd.net account.
  final String apiKey;

  /// Sender ID approved in your bulksmsbd.net account.
  final String senderId;

  final http.Client _client;
  bool _isClosed = false;

  static const String _baseUrl = 'https://bulksmsbd.net/api';
  static const Duration _timeout = Duration(seconds: 30);

  /// Creates a new API client.
  ///
  /// An optional [client] can be injected for testing with a mock HTTP client.
  /// Throws [ArgumentError] if [apiKey] or [senderId] are empty.
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

  /// Sends an SMS to one or more [numbers] with the given [message].
  ///
  /// [numbers] are joined with commas and sent in a single API request.
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

  /// Sends different [messages] to different numbers (bulk SMS).
  ///
  /// Each [BulkSmsBulkItem] specifies a recipient and their message.
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

  /// Sends a branded OTP to [number].
  ///
  /// Uses [brandName] in the message template:
  /// `"Your $brandName OTP is $otp"`.
  Future<BulkSmsResponse> sendOtp({
    required String number,
    required String brandName,
    required String otp,
  }) {
    final formattedMessage = 'Your $brandName OTP is $otp';
    return sendSms(numbers: [number], message: formattedMessage);
  }

  /// Checks the remaining SMS balance.
  ///
  /// Returns the balance string (e.g., `"5000"`) on success, or an error
  /// message prefixed with `"Error: "` on failure.
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

  /// Releases the underlying HTTP client resources.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops.
  void close() {
    if (!_isClosed) {
      _isClosed = true;
      _client.close();
    }
  }
}

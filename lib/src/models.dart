/// Represents a response from the bulksmsbd.net API.
///
/// Contains the status [code], a human-readable [message], and a convenience
/// [isSuccess] flag indicating whether the request succeeded (code `202`).
class BulkSmsResponse {
  /// API response code (e.g., `202` for success, `1001` for invalid number).
  final String successCode;

  /// Human-readable message from the API or a fallback description.
  final String message;

  /// Whether the request completed successfully (`successCode == '202'`).
  final bool isSuccess;

  /// Creates a [BulkSmsResponse] with the given values.
  BulkSmsResponse({
    required this.successCode,
    required this.message,
    required this.isSuccess,
  });

  /// Parses a JSON map from the API into a [BulkSmsResponse].
  ///
  /// Falls back to known error messages when the API does not include one.
  factory BulkSmsResponse.fromJson(Map<String, dynamic> json) {
    final code = json['response_code']?.toString() ?? '1005';
    final rawMsg = json['success_message'] ?? json['error_message'] ?? '';
    final msg = rawMsg is String && rawMsg.isNotEmpty
        ? rawMsg
        : getErrorMessage(code);

    return BulkSmsResponse(
      successCode: code,
      message: msg,
      isSuccess: code == '202',
    );
  }

  static const Map<String, String> _errorCodes = {
    '202': 'SMS Submitted Successfully',
    '1001': 'Invalid Number',
    '1002': 'Sender ID not correct / sender ID is disabled',
    '1003': 'Please Required all fields / Contact Your System Administrator',
    '1005': 'Internal Error',
    '1006': 'Balance Validity Not Available',
    '1007': 'Balance Insufficient',
    '1011': 'User Id not found',
    '1012': 'Masking SMS must be sent in Bengali',
    '1013': 'Sender Id has not found Gateway by api key',
    '1014': 'Sender Type Name not found using this sender by api key',
    '1015': 'Sender Id has not found Any Valid Gateway by api key',
    '1016': 'Sender Type Name Active Price Info not found by this sender id',
    '1017': 'Sender Type Name Price Info not found by this sender id',
    '1018': 'The Owner of this account username is disabled',
    '1019': 'The sender type name price of this account username is disabled',
    '1020': 'The parent of this account is not found.',
    '1021': 'The parent active sender type name price of this account is not found.',
    '1031': 'Your Account Not Verified, Please Contact Administrator.',
    '1032': 'IP Not whitelisted',
  };

  /// Returns a human-readable message for the given API [code].
  ///
  /// Returns `"Unknown Error occurred (Code: $code)"` for unknown codes.
  static String getErrorMessage(String code) =>
      _errorCodes[code] ?? 'Unknown Error occurred (Code: $code)';
}

/// An item for bulk SMS, pairing a recipient number with a message.
class BulkSmsBulkItem {
  /// Recipient phone number (e.g., `88017XXXXXXXX`).
  final String to;

  /// Message content to send to this recipient.
  final String message;

  /// Creates a bulk SMS item for [to] with the given [message].
  BulkSmsBulkItem({required this.to, required this.message});

  /// Converts this item to a JSON-compatible map for the API request body.
  Map<String, String> toJson() => {
        'to': to,
        'message': message,
      };
}

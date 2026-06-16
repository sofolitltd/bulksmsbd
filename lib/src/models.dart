class BulkSmsResponse {
  final String successCode;
  final String message;
  final bool isSuccess;

  BulkSmsResponse({
    required this.successCode,
    required this.message,
    required this.isSuccess,
  });

  factory BulkSmsResponse.fromJson(Map<String, dynamic> json) {
    final code = json['response_code']?.toString() ?? '1005';
    final rawMsg = (json['success_message'] ?? json['error_message'] ?? '') as String;
    final msg = rawMsg.isNotEmpty ? rawMsg : getErrorMessage(code);

    return BulkSmsResponse(
      successCode: code,
      message: msg,
      isSuccess: code == '202',
    );
  }

  static String getErrorMessage(String code) {
    final Map<String, String> errorCodes = {
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

    return errorCodes[code] ?? 'Unknown Error occurred (Code: $code)';
  }
}

class BulkSmsBulkItem {
  final String to;
  final String message;

  BulkSmsBulkItem({required this.to, required this.message});

  Map<String, String> toJson() => {
        'to': to,
        'message': message,
      };
}

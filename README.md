# bulksmsbd

A robust, production-ready Dart & Flutter wrapper for the [bulksmsbd.net](https://bulksmsbd.net) SMS gateway API. Developed and maintained by **Sofol IT**.

## Features

- Send SMS to single or multiple numbers
- Send different messages to different numbers (bulk SMS)
- Send OTP messages with branded sender name
- Check account balance
- Comprehensive error handling with descriptive messages
- Supports all bulksmsbd.net error codes

## Getting started

### Prerequisites

- Dart SDK `>=3.0.0 <4.0.0`
- An active [bulksmsbd.net](https://bulksmsbd.net) account
- API key and approved Sender ID from your account dashboard

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  bulksmsbd: ^1.0.0
```

## Usage

### Import

```dart
import 'package:bulksmsbd/bulksmsbd.dart';
```

### Initialize client

```dart
final smsClient = BulkSmsBd(
  apiKey: 'your_api_key',
  senderId: 'your_sender_id',
);
```

### Send SMS to one or more numbers

```dart
final response = await smsClient.sendSms(
  numbers: ['88017XXXXXXXX', '88018XXXXXXXX'],
  message: 'Your message here',
);

if (response.isSuccess) {
  print('SMS sent: ${response.message}');
} else {
  print('Failed: ${response.message}');
}
```

### Send different messages to different numbers

```dart
final response = await smsClient.sendBulkSms(messages: [
  BulkSmsBulkItem(to: '88017XXXXXXXX', message: 'First message'),
  BulkSmsBulkItem(to: '88018XXXXXXXX', message: 'Second message'),
]);
```

### Send OTP

```dart
final response = await smsClient.sendOtp(
  number: '88017XXXXXXXX',
  brandName: 'YourBrand',
  otp: '123456',
);
// Sends: "Your YourBrand OTP is 123456"
```

### Check balance

```dart
final balance = await smsClient.getBalance();
print('Remaining balance: $balance BDT');
```

### Clean up

```dart
smsClient.close();
```

## API Reference

### `BulkSmsBd`

| Method | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `sendSms` | `numbers`, `message` | `BulkSmsResponse` | Send SMS to comma-joined numbers |
| `sendBulkSms` | `messages` | `BulkSmsResponse` | Send different messages to different numbers |
| `sendOtp` | `number`, `brandName`, `otp` | `BulkSmsResponse` | Convenience method for OTP SMS |
| `getBalance` | — | `String` | Check remaining account balance |
| `close` | — | `void` | Release HTTP client resources |

### `BulkSmsResponse`

| Property | Type | Description |
|----------|------|-------------|
| `successCode` | `String` | API response code |
| `message` | `String` | Success or error message |
| `isSuccess` | `bool` | `true` when code is `202` |

### Response codes

| Code | Meaning |
|------|---------|
| 202 | SMS submitted successfully |
| 1001 | Invalid number |
| 1002 | Sender ID not correct / disabled |
| 1003 | Required fields missing / Contact system administrator |
| 1005 | Internal error |
| 1006 | Balance validity not available |
| 1007 | Balance insufficient |
| 1011 | User ID not found |
| 1012 | Masking SMS must be sent in Bengali |
| 1013 | Sender ID has not found gateway by API key |
| 1014 | Sender type name not found using this sender by API key |
| 1015 | Sender ID has not found any valid gateway by API key |
| 1016 | Sender type name active price info not found |
| 1017 | Sender type name price info not found |
| 1018 | The owner of this account is disabled |
| 1019 | Sender type name price of this account is disabled |
| 1020 | The parent of this account is not found |
| 1021 | The parent active sender type name price not found |
| 1031 | Account not verified — contact administrator |
| 1032 | IP not whitelisted |

## Additional information

- **Homepage:** [https://sofolit.vercel.app](https://sofolit.vercel.app)
- **Repository:** [https://github.com/sofolitltd/bulksmsbd](https://github.com/sofolitltd/bulksmsbd)
- **Issue tracker:** [https://github.com/sofolitltd/bulksmsbd/issues](https://github.com/sofolitltd/bulksmsbd/issues)

Contributions are welcome. Please file issues or submit pull requests on GitHub.

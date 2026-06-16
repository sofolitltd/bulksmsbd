# BulkSMS BD Demo

Flutter demo application for the [bulksmsbd](https://pub.dev/packages/bulksmsbd) package.

## Prerequisites

- An active [bulksmsbd.net](https://bulksmsbd.net) account
- API key and approved Sender ID from your account dashboard
- IP whitelisting must be disabled (see Account Setup)

## Account Setup

Before using the demo, disable IP whitelisting in your bulksmsbd.net account:

1. Log in to your [bulksmsbd.net](https://bulksmsbd.net) dashboard
2. Go to **Phone Book** → **IP White List**
3. At the top, in **IP White Listing Setting**, toggle to **disabled**
4. Enter the OTP sent to your registered mobile number

## Environment Configuration

Create a `.env` file in the `demo/` directory (or copy from `.env.example`):

```env
API_KEY=your_api_key_here
SENDER_ID=your_sender_id_here
```

> ⚠️ The `.env` file is gitignored. Never commit real credentials.

## Features

| Page | Description |
|------|-------------|
| **Check Balance** | View remaining SMS credit balance |
| **Send SMS** | Send a message to one or multiple numbers |
| **Send OTP** | Send a branded OTP to a phone number |
| **Bulk SMS** | Send different messages to different numbers |

## Run

```bash
cd demo
flutter run
```

# QRush

A QR code generator, scanner and manager built with Flutter.

## Features
- 24 QR types: URL, Wi-Fi, vCard, UPI, WhatsApp, Event, PDF/Video/Audio links and more
- Custom QR designs: 12 templates, body and eye shapes, gradients, logo embedding
- Export as PNG, JPG or PDF, and share
- Camera QR scanner with smart content detection
- My QR Library: save, search, favorite and regenerate
- File upload to QR using Supabase Storage
- Responsive: website layout on laptop, mobile layout on phone

## Tech stack
Flutter, Dart, CustomPaint, mobile_scanner, Supabase Storage, SharedPreferences

## Run locally
1. `flutter pub get`
2. Copy `lib/secrets.example.dart` to `lib/secrets.dart` and add your Supabase URL and key
3. `flutter run -d chrome`
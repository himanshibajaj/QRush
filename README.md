# QRush

**A QR code generator, scanner and manager built with Flutter.** Create custom-designed QR codes, scan them with your camera, and keep everything in a personal library.

**Platforms:** Web · Android (in progress)

## Features

- **24 QR types:** website, text, Wi-Fi, vCard/MeCard, email, phone, SMS, location (address or coordinates), event, UPI, WhatsApp, social links, PDF/video/audio links and more
- **Custom designs:** 12 templates, 6 body shapes, 4 eye-frame and 5 eye-ball styles, gradients, custom eye colour, logo upload or ready-made logo icons
- **Scan-quality check:** warns about low contrast or too much data before you print
- **Smart scanner:** camera scanning with automatic content detection (link, Wi-Fi, contact, UPI and more) and Open / Copy / Save actions
- **My QR Library:** save with title, purpose and recipient; search, favorite, regenerate and share
- **Export:** PNG, JPG or PDF, plus native sharing
- **File-to-QR:** upload a PDF, image, audio or video to Supabase Storage and get a QR that opens it
- **Responsive:** website layout on laptop (form and live preview side by side), mobile layout on phone

## How it works

- The QR matrix comes from the `qr` package. A custom `CustomPaint` renderer draws every module, eye frame and eye ball, so shapes, gradients and logos are fully controlled.
- The same renderer powers the live preview, the library and the PNG/JPG/PDF export, so what you see is what you download.
- Saved QR codes store only their content and design settings. The image is regenerated on demand.

## Tech stack

| Technology | Purpose |
|---|---|
| Flutter, Dart | App framework and language |
| qr + CustomPaint | Custom QR rendering |
| mobile_scanner | QR and barcode scanning |
| Supabase Storage | File uploads (via REST) |
| shared_preferences | Local QR library |
| pdf, image, file_saver, share_plus | Export and sharing |
| image_picker, file_picker | Logo and file selection |

## Run locally

```bash
git clone https://github.com/himanshibajaj/QRush.git
cd QRush
flutter pub get
```

1. Copy `lib/secrets.example.dart` to `lib/secrets.dart` and add your Supabase project URL and key.
2. Run in Chrome: `flutter run -d chrome`
3. Run on Android: connect a device and run `flutter run`

## Supabase setup (for file upload)

1. Create a free project at supabase.com.
2. Storage: create a **public** bucket named `qr-files`.
3. SQL Editor: run

```sql
create policy "qr-files public upload"
on storage.objects for insert
to anon
with check (bucket_id = 'qr-files');
```

4. Put the project URL and anon key in `lib/secrets.dart`.

Note: this demo allows anonymous uploads. For production, use authenticated uploads and file-size and type limits.

## Project structure

```
lib/
  main.dart, main_shell.dart       app shell and responsive navigation
  qr_types.dart                    24 QR types and their content builders
  qr_painter.dart, qr_style.dart   custom QR renderer and design model
  design_panel.dart                templates, colours, logo and shape controls
  create_screen.dart               create flow with live preview
  scan_screen.dart                 camera scanner and result screen
  library_screen.dart              saved QR library
  qr_export.dart, upload_service.dart, qr_store.dart
```

## Roadmap

- Dark mode and multiple languages (English, Hindi, Marathi)
- Bulk QR generation
- Android release build
- Cloud sync with user accounts
- Dynamic QR codes and scan analytics

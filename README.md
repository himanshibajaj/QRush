# QRush — Create. Customize. Connect.

**One platform. Every QR code. Everything in one place.**

QRush is a feature-rich QR Code Generator, Scanner, and Manager built with Flutter. It transforms everyday information into customizable, shareable QR codes while keeping everything organized in one place.

Whether you want to share a website, connect someone to Wi-Fi, exchange contact details, share a document, or create a QR code for a payment, QRush makes the process simple, fast, and convenient.

## Why QRush?

Creating a QR code is easy. Managing it later shouldn't be difficult.

QRush goes beyond basic QR generation by combining powerful customization tools, smart scanning, multiple export formats, and a personal QR library.

Generate it once. Save it. Find it anytime. Share it whenever you need it.

## Features

### 1. Multiple QR Code Types

Generate QR codes for 24 different content types, including:

- Website URLs and plain text
- Wi-Fi credentials
- Contact cards (vCard)
- Email, phone numbers, and SMS
- UPI payment details
- WhatsApp and social media
- Events and location information
- PDF, video, and audio links
- And more

### 2. Advanced QR Customization

Give every QR code its own design.

- 12 ready-to-use design templates
- Multiple QR body and eye shapes
- Custom foreground and background colors
- Gradient color customization
- Logo embedding
- Live QR code preview

### 3. Smart QR Scanner

Scan QR codes directly using your device camera.

- Real-time QR code scanning
- Automatic content detection
- Quick access to detected links and information

### 4. My QR Library — Your Codes, Always Organized

Never lose track of a QR code you've created.

- Save generated QR codes for future use
- Add titles, descriptions, and personal notes
- View creation history
- Search saved QR codes
- Mark frequently used codes as favorites
- Regenerate previously saved QR codes
- Share or export saved QR codes anytime

### 5. Multiple Export Options

Take your QR codes wherever you need them.

- Download as PNG
- Export as JPG
- Generate PDF files
- Share QR codes directly

### 6. File-to-QR Sharing

Upload files using Supabase Storage and generate shareable QR codes linked to those files.

Supports document, audio, and video sharing through accessible file links.

### 7. Responsive Interface

QRush adapts to different screen sizes, providing a mobile-friendly interface and a website-style layout on larger screens.

## Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Application development |
| Dart | Programming language |
| CustomPaint | QR design and customization |
| mobile_scanner | QR code scanning |
| Supabase Storage | File uploads and storage |
| SharedPreferences | Local preferences and data |

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Supabase account for file upload functionality

### Installation

1. Clone the repository:

   ```bash
   git clone YOUR_REPOSITORY_URL
   ```

2. Navigate to the project directory:

   ```bash
   cd qrush
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Configure Supabase:

   Copy `lib/secrets.example.dart` to `lib/secrets.dart` and add your Supabase project URL and key.

5. Run the application in Chrome:

   ```bash
   flutter run -d chrome
   ```

   For Android, connect a device or start an emulator and run:

   ```bash
   flutter run
   ```

## Project Highlights

- Combines QR generation, scanning, customization, and management in one application.
- Provides 24 different QR content types.
- Offers advanced design controls beyond basic QR generation.
- Includes a personal QR library with search, favorites, and regeneration.
- Integrates cloud file storage for file-based QR sharing.
- Built with Flutter for cross-platform development.

## Future Enhancements

- Cloud-based QR backup and synchronization
- User authentication and personalized profiles
- QR code analytics and scan statistics
- Password-protected QR codes
- Bulk QR code generation
- Improved library organization and categories

## About the Project

QRush is a Flutter-based project focused on making QR code creation and management more accessible, customizable, and organized.

The goal is simple: make sharing information as easy as generating a QR code.

---

**QRush — Create. Customize. Connect.**

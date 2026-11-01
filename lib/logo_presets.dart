import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class LogoPreset {
  final String name;
  final IconData icon;
  final Color bg;
  final Color fg;
  final double scale; // icon, circle ke kitne hisse mein
  const LogoPreset(this.name, this.icon, this.bg, this.fg, this.scale);
}

const logoPresets = <LogoPreset>[
  LogoPreset('Facebook', Icons.facebook, Colors.white, Color(0xFF1877F2), 1.0),
  LogoPreset('Instagram', Icons.camera_alt, Color(0xFFE1306C), Colors.white, 0.55),
  LogoPreset('YouTube', Icons.smart_display, Color(0xFFFF0000), Colors.white, 0.6),
  LogoPreset('X', Icons.alternate_email, Color(0xFF111827), Colors.white, 0.58),
  LogoPreset('LinkedIn', Icons.work, Color(0xFF0A66C2), Colors.white, 0.55),
  LogoPreset('WhatsApp', Icons.chat, Color(0xFF25D366), Colors.white, 0.55),
  LogoPreset('Telegram', Icons.send, Color(0xFF229ED9), Colors.white, 0.52),
  LogoPreset('Gmail', Icons.email, Color(0xFFEA4335), Colors.white, 0.55),
  LogoPreset('Play Store', Icons.play_arrow, Color(0xFF01875F), Colors.white, 0.65),
  LogoPreset('App Store', Icons.storefront, Color(0xFF0D96F6), Colors.white, 0.55),
  LogoPreset('Website', Icons.language, Color(0xFF4F46E5), Colors.white, 0.62),
  LogoPreset('Phone', Icons.call, Color(0xFF16A34A), Colors.white, 0.55),
  LogoPreset('Location', Icons.location_on, Color(0xFFEF4444), Colors.white, 0.6),
  LogoPreset('Wi-Fi', Icons.wifi, Color(0xFF0891B2), Colors.white, 0.6),
  LogoPreset('UPI', Icons.account_balance_wallet, Color(0xFF15803D), Colors.white, 0.55),
  LogoPreset('Bitcoin', Icons.currency_bitcoin, Color(0xFFF7931A), Colors.white, 0.75),
  LogoPreset('Document', Icons.description, Color(0xFFD99A5B), Colors.white, 0.55),
  LogoPreset('Calendar', Icons.event, Color(0xFF475569), Colors.white, 0.55),
  LogoPreset('Share', Icons.share, Color(0xFF2E8BA6), Colors.white, 0.55),
  LogoPreset('Heart', Icons.favorite, Color(0xFFE11D48), Colors.white, 0.55),
];

/// Preset ko PNG image bana deta hai, taaki upload kiye logo ki tarah hi use ho.
Future<Uint8List> renderPresetLogo(LogoPreset p, {double size = 256}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawCircle(Offset(size / 2, size / 2), size / 2, Paint()..color = p.bg);

  final tp = TextPainter(textDirection: TextDirection.ltr)
    ..text = TextSpan(
      text: String.fromCharCode(p.icon.codePoint),
      style: TextStyle(
        fontSize: size * p.scale,
        fontFamily: p.icon.fontFamily,
        package: p.icon.fontPackage,
        color: p.fg,
      ),
    )
    ..layout();
  tp.paint(canvas, Offset((size - tp.width) / 2, (size - tp.height) / 2));

  final image =
      await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}
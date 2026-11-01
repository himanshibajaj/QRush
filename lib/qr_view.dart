import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'theme.dart';

/// Ek hi jagah se QR banta hai: Create, Library aur Detail teeno yahi use karte hain.
Widget qrWidget({
  required String data,
  required double size,
  required Color fg,
  required Color bg,
  bool roundDots = false,
  bool roundEyes = false,
  Uint8List? logo,
}) {
  return QrImageView(
    data: data,
    size: size,
    backgroundColor: bg,
    // 0 = Medium, 2 = High (logo ke saath High zaroori hai)
    errorCorrectionLevel: logo != null ? 2 : 0,
    embeddedImage: logo != null ? MemoryImage(logo) : null,
    embeddedImageStyle: logo != null
        ? QrEmbeddedImageStyle(size: Size(size * 0.22, size * 0.22))
        : null,
    errorStateBuilder: (c, e) => SizedBox(
      width: size,
      height: size,
      child: const Center(
        child: Text('Too much data\nfor one QR', textAlign: TextAlign.center),
      ),
    ),
    eyeStyle: QrEyeStyle(
      eyeShape: roundEyes ? QrEyeShape.circle : QrEyeShape.square,
      color: fg,
    ),
    dataModuleStyle: QrDataModuleStyle(
      dataModuleShape:
          roundDots ? QrDataModuleShape.circle : QrDataModuleShape.square,
      color: fg,
    ),
  );
}

List<String> qrWarnings({
  required Color fg,
  required Color bg,
  required int dataLength,
}) {
  final w = <String>[];
  final lf = fg.computeLuminance();
  final lb = bg.computeLuminance();
  final hi = lf > lb ? lf : lb;
  final lo = lf > lb ? lb : lf;
  final ratio = (hi + 0.05) / (lo + 0.05);

  if (ratio < 3) {
    w.add('Low contrast between the QR and its background. It may not scan.');
  } else if (lf > lb) {
    w.add('Light QR on a dark background. Some scanner apps cannot read this.');
  }
  if (dataLength > 400) {
    w.add('A lot of data makes the QR very dense. Shorten the content or print it larger.');
  }
  return w;
}

class QrQualityBadge extends StatelessWidget {
  final List<String> warnings;
  const QrQualityBadge({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    final ok = warnings.isEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ok ? Colors.white : const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: ok ? AppColors.border : const Color(0xFFFFD8A8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ok ? Icons.verified_outlined : Icons.warning_amber_rounded,
            size: 20,
            color: ok ? AppColors.primary : const Color(0xFFB45309),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ok
                ? const Text('Good scan quality',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final t in warnings)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(t, style: const TextStyle(fontSize: 13)),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
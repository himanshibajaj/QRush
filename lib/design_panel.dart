import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'color_field.dart';
import 'logo_presets.dart';
import 'qr_painter.dart';
import 'qr_style.dart';
import 'theme.dart';

const _fgPresets = [
  Color(0xFF1E1B4B),
  Color(0xFF4F46E5),
  Color(0xFF000000),
  Color(0xFF14532D),
  Color(0xFF991B1B),
  Color(0xFFB45309),
  Color(0xFF0F766E),
  Color(0xFF9D174D),
];
const _bgPresets = [
  Color(0xFFFFFFFF),
  Color(0xFFEEF0FF),
  Color(0xFFFFF7D6),
  Color(0xFFE6FFF9),
  Color(0xFFFFE3F1),
  Color(0xFFF1F5F9),
];
const _gradientDefault = Color(0xFF7E22CE);

Widget _chipRow<T>(String label, List<T> options, T selected,
    String Function(T) name, ValueChanged<T> onPick) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      Wrap(
        spacing: 8,
        children: [
          for (final o in options)
            ChoiceChip(
              label: Text(name(o)),
              selected: selected == o,
              selectedColor: AppColors.soft,
              onSelected: (_) => onPick(o),
            ),
        ],
      ),
    ],
  );
}

// ---------------- Templates ----------------
class TemplatesSection extends StatelessWidget {
  final ValueChanged<QrStyle> onPick;
  const TemplatesSection({super.key, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 122,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: qrTemplates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final t = qrTemplates[i];
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onPick(t.style),
            child: Container(
              width: 92,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: StyledQr(data: 'QRush', size: 74, style: t.style),
                  ),
                  const SizedBox(height: 6),
                  Text(t.name,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------- Colours ----------------
class ColorsSection extends StatelessWidget {
  final QrStyle style;
  final ValueChanged<QrStyle> onChanged;
  const ColorsSection({super.key, required this.style, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _chipRow<String>(
          'Colour mode',
          const ['Single colour', 'Gradient'],
          style.fg2 == null ? 'Single colour' : 'Gradient',
          (s) => s,
          (o) => onChanged(o == 'Gradient'
              ? style.copyWith(fg2: style.fg2 ?? _gradientDefault)
              : style.copyWith(clearFg2: true)),
        ),
        const SizedBox(height: 16),
        ColorField(
          key: const ValueKey('fg'),
          label: style.fg2 == null ? 'QR colour' : 'Gradient start colour',
          color: style.fg,
          presets: _fgPresets,
          startOpen: true,
          onChanged: (c) => onChanged(style.copyWith(fg: c)),
        ),
        if (style.fg2 != null) ...[
          const SizedBox(height: 20),
          ColorField(
            key: const ValueKey('fg2'),
            label: 'Gradient end colour',
            color: style.fg2!,
            presets: _fgPresets,
            onChanged: (c) => onChanged(style.copyWith(fg2: c)),
          ),
        ],
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
          title: const Text('Custom eye colour'),
          subtitle: const Text('Colour of the three corner squares'),
          value: style.eye != null,
          onChanged: (v) => onChanged(
              v ? style.copyWith(eye: style.fg) : style.copyWith(clearEye: true)),
        ),
        if (style.eye != null) ...[
          const SizedBox(height: 8),
          ColorField(
            key: const ValueKey('eye'),
            label: 'Eye colour',
            color: style.eye!,
            presets: _fgPresets,
            onChanged: (c) => onChanged(style.copyWith(eye: c)),
          ),
        ],
        const SizedBox(height: 20),
        ColorField(
          key: const ValueKey('bg'),
          label: 'Background colour',
          color: style.bg,
          presets: _bgPresets,
          onChanged: (c) => onChanged(style.copyWith(bg: c)),
        ),
      ],
    );
  }
}

// ---------------- Logo ----------------
class LogoSection extends StatelessWidget {
  final Uint8List? logo;
  final bool clearBg;
  final VoidCallback onUpload;
  final ValueChanged<LogoPreset> onPreset;
  final VoidCallback onRemove;
  final ValueChanged<bool> onClearBg;

  const LogoSection({
    super.key,
    required this.logo,
    required this.clearBg,
    required this.onUpload,
    required this.onPreset,
    required this.onRemove,
    required this.onClearBg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              alignment: Alignment.center,
              child: logo == null
                  ? const Text('NO LOGO',
                      style: TextStyle(fontSize: 12, color: Colors.black45))
                  : Padding(
                      padding: const EdgeInsets.all(6),
                      child: Image.memory(logo!, fit: BoxFit.contain),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    onPressed: onUpload,
                    icon: const Icon(Icons.upload, size: 18),
                    label: Text(logo == null ? 'Upload image' : 'Change image'),
                  ),
                  if (logo != null)
                    TextButton(
                        onPressed: onRemove, child: const Text('Remove logo')),
                ],
              ),
            ),
          ],
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primary,
          title: const Text('Remove background behind logo'),
          value: clearBg,
          onChanged: (v) => onClearBg(v ?? true),
        ),
        const SizedBox(height: 4),
        const Text('Or pick a ready-made logo',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final p in logoPresets)
              Tooltip(
                message: p.name,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onPreset(p),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration:
                          BoxDecoration(color: p.bg, shape: BoxShape.circle),
                      child: Icon(p.icon, color: p.fg, size: 38 * p.scale),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'The logo sits in the centre at a safe size. If a QR with a logo does not scan, remove the logo or use a simpler design.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

// ---------------- Shapes ----------------
class ShapesSection extends StatelessWidget {
  final QrStyle style;
  final ValueChanged<QrStyle> onChanged;
  const ShapesSection({super.key, required this.style, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _chipRow<BodyShape>('Body shape', BodyShape.values, style.body,
            (o) => bodyNames[o]!, (o) => onChanged(style.copyWith(body: o))),
        const SizedBox(height: 16),
        _chipRow<FrameShape>('Eye frame', FrameShape.values, style.frame,
            (o) => frameNames[o]!, (o) => onChanged(style.copyWith(frame: o))),
        const SizedBox(height: 16),
        _chipRow<BallShape>('Eye ball', BallShape.values, style.ball,
            (o) => ballNames[o]!, (o) => onChanged(style.copyWith(ball: o))),
        const SizedBox(height: 12),
        const Text(
          'Tip: Square and Rounded are the most reliable to scan. Always test a fancy design with your phone.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
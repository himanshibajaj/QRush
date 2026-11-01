import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'theme.dart';

String colorToHex(Color c) =>
    c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();

class ColorField extends StatefulWidget {
  final String label;
  final Color color;
  final List<Color> presets;
  final ValueChanged<Color> onChanged;
  final bool startOpen;

  const ColorField({
    super.key,
    required this.label,
    required this.color,
    required this.presets,
    required this.onChanged,
    this.startOpen = false,
  });

  @override
  State<ColorField> createState() => _ColorFieldState();
}

class _ColorFieldState extends State<ColorField> {
  late final TextEditingController _c =
      TextEditingController(text: colorToHex(widget.color));
  late bool _open = widget.startOpen;

  @override
  void didUpdateWidget(ColorField old) {
    super.didUpdateWidget(old);
    final hex = colorToHex(widget.color);
    if (old.color != widget.color &&
        _c.text.toUpperCase().replaceAll('#', '') != hex) {
      _c.text = hex;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _onText(String v) {
    final t = v.replaceAll('#', '').trim();
    if (RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(t)) {
      widget.onChanged(Color(int.parse('FF$t', radix: 16)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _open = !_open),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _c,
                maxLength: 7,
                onChanged: _onText,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  prefixText: '#  ',
                  counterText: '',
                  hintText: '4F46E5',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Colour palette',
              icon: Icon(_open ? Icons.expand_less : Icons.palette_outlined,
                  color: AppColors.primary),
              onPressed: () => setState(() => _open = !_open),
            ),
          ],
        ),
        if (_open) ...[
          const SizedBox(height: 12),
          HsvPicker(color: widget.color, onChanged: widget.onChanged),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final p in widget.presets)
              GestureDetector(
                onTap: () => widget.onChanged(p),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: p,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: p == widget.color
                          ? AppColors.primary
                          : AppColors.border,
                      width: p == widget.color ? 3 : 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// QR Monkey jaisa picker: upar saturation/brightness ka square, neeche hue bar.
class HsvPicker extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onChanged;
  const HsvPicker({super.key, required this.color, required this.onChanged});

  @override
  State<HsvPicker> createState() => _HsvPickerState();
}

class _HsvPickerState extends State<HsvPicker> {
  late HSVColor _hsv = HSVColor.fromColor(widget.color);
  static const double _areaHeight = 190;

  @override
  void didUpdateWidget(HsvPicker old) {
    super.didUpdateWidget(old);
    if (widget.color.value != _hsv.toColor().value) {
      _hsv = HSVColor.fromColor(widget.color);
    }
  }

  void _emit(HSVColor c) {
    setState(() => _hsv = c);
    widget.onChanged(c.toColor());
  }

  Widget _thumb(Color fill, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final hueColor = HSVColor.fromAHSV(1, _hsv.hue, 1, 1).toColor();

    return Column(
      children: [
        LayoutBuilder(builder: (context, cons) {
          final w = cons.maxWidth;
          void update(Offset p) {
            final s = (p.dx / w).clamp(0.0, 1.0);
            final v = 1 - (p.dy / _areaHeight).clamp(0.0, 1.0);
            _emit(_hsv.withSaturation(s).withValue(v));
          }

          return _DragArea(
            onUpdate: update,
            child: SizedBox(
              width: w,
              height: _areaHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Container(
                            width: w, height: _areaHeight, color: hueColor),
                        Container(
                          width: w,
                          height: _areaHeight,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Color(0x00FFFFFF)],
                            ),
                          ),
                        ),
                        Container(
                          width: w,
                          height: _areaHeight,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x00000000), Colors.black],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: _hsv.saturation * w - 11,
                    top: (1 - _hsv.value) * _areaHeight - 11,
                    child: _thumb(_hsv.toColor(), 22),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 14),
        LayoutBuilder(builder: (context, cons) {
          final w = cons.maxWidth;
          void update(Offset p) {
            final h = (p.dx / w).clamp(0.0, 1.0) * 360;
            _emit(_hsv.withHue(h));
          }

          return _DragArea(
            onUpdate: update,
            child: SizedBox(
              width: w,
              height: 24,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(colors: [
                          for (var i = 0; i <= 6; i++)
                            HSVColor.fromAHSV(1, i * 60.0, 1, 1).toColor(),
                        ]),
                      ),
                    ),
                  ),
                  Positioned(
                    left: _hsv.hue / 360 * w - 12,
                    top: 0,
                    child: _thumb(hueColor, 24),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Drag karte waqt list scroll na ho, isliye gesture "eagerly" pakadte hain.
class _DragArea extends StatelessWidget {
  final void Function(Offset) onUpdate;
  final Widget child;
  const _DragArea({required this.onUpdate, required this.child});

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        EagerGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
          () => EagerGestureRecognizer(),
          (EagerGestureRecognizer instance) {},
        ),
      },
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) => onUpdate(e.localPosition),
        onPointerMove: (e) => onUpdate(e.localPosition),
        child: child,
      ),
    );
  }
}
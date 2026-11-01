import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'design_panel.dart';
import 'logo_presets.dart';
import 'qr_export.dart';
import 'qr_painter.dart';
import 'qr_store.dart';
import 'qr_style.dart';
import 'qr_types.dart';
import 'qr_view.dart';
import 'responsive.dart';
import 'saved_qr.dart';
import 'theme.dart';
import 'upload_service.dart';

class CreateScreen extends StatefulWidget {
  final QrType type;
  const CreateScreen({super.key, required this.type});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final Map<String, String> vals = {};
  final Map<String, TextEditingController> _ctrls = {};

  QrStyle style = const QrStyle();
  Uint8List? logo;
  bool logoClearBg = true;

  // upload
  bool uploadMode = false;
  bool uploading = false;
  String? uploadedName;
  String? uploadError;

  @override
  void initState() {
    super.initState();
    for (final f in widget.type.fields) {
      if (f.kind == FieldKind.choice) vals[f.key] = f.options.first;
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrl(String key) => _ctrls.putIfAbsent(
      key, () => TextEditingController(text: vals[key] ?? ''));

  bool _visible(QrField f) =>
      f.dependsOn == null || vals[f.dependsOn!] == f.dependsValue;

  String get payload => widget.type.build(Vals(vals));

  List<String> _warnings(String data) {
    final w = <String>{};
    w.addAll(qrWarnings(fg: style.fg, bg: style.bg, dataLength: data.length));
    if (style.fg2 != null) {
      w.addAll(
          qrWarnings(fg: style.fg2!, bg: style.bg, dataLength: data.length));
    }
    return w.toList();
  }

  // ---------------- pickers ----------------
  Future<void> _pickDateTime(QrField f) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null || !mounted) return;
    final t =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t == null) return;
    final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    setState(() => vals[f.key] = dt.toIso8601String().split('.').first);
  }

  Future<void> _pickLogo() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      imageQuality: 85,
    );
    if (x == null) return;
    final bytes = await x.readAsBytes();
    if (!mounted) return;
    setState(() => logo = bytes);
  }

  Future<void> _usePreset(LogoPreset p) async {
    final bytes = await renderPresetLogo(p);
    if (!mounted) return;
    setState(() => logo = bytes);
  }

  void _setMode(bool upload) {
    setState(() {
      uploadMode = upload;
      vals.remove('link');
      _ctrls['link']?.clear();
      uploadedName = null;
      uploadError = null;
    });
  }

  Future<void> _upload(UploadKind kind) async {
    setState(() {
      uploading = true;
      uploadError = null;
    });
    try {
      final r = await pickAndUpload(kind);
      if (!mounted) return;
      if (r != null) {
        setState(() {
          vals['link'] = r.url;
          uploadedName = r.name;
        });
      }
    } catch (e) {
      if (mounted) setState(() => uploadError = e.toString());
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  // ---------------- small UI helpers ----------------
  InputDecoration _deco(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      );

  Widget _chipRow(String label, List<String> options, String selected,
      ValueChanged<String> onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child:
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Wrap(
          spacing: 8,
          children: [
            for (final o in options)
              ChoiceChip(
                label: Text(o),
                selected: selected == o,
                selectedColor: AppColors.soft,
                onSelected: (_) => onPick(o),
              ),
          ],
        ),
      ],
    );
  }

  Widget _field(QrField f) {
    switch (f.kind) {
      case FieldKind.choice:
        return _chipRow(f.label, f.options, vals[f.key] ?? f.options.first,
            (o) => setState(() => vals[f.key] = o));
      case FieldKind.datetime:
        final raw = vals[f.key];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _pickDateTime(f),
          child: InputDecorator(
            decoration:
                _deco(f.label).copyWith(suffixIcon: const Icon(Icons.event)),
            child: Text(
              raw == null
                  ? 'Tap to pick date & time'
                  : fmtDate(DateTime.parse(raw)),
              style: TextStyle(color: raw == null ? Colors.black45 : null),
            ),
          ),
        );
      case FieldKind.text:
        return TextField(
          controller: _ctrl(f.key),
          keyboardType: f.lines > 1 ? TextInputType.multiline : f.keyboard,
          minLines: f.lines,
          maxLines: f.lines,
          onChanged: (v) => setState(() => vals[f.key] = v),
          decoration: _deco(f.label),
        );
    }
  }

  Widget _uploadPanel(UploadKind kind) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: uploading ? null : () => _upload(kind),
            icon: uploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file),
            label: Text(uploading
                ? 'Uploading...'
                : (uploadedName == null
                    ? 'Choose ${kind.noun}'
                    : 'Choose a different ${kind.noun}')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        if (uploadedName != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Uploaded: $uploadedName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        if (uploadError != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(uploadError!,
                style: const TextStyle(
                    color: Color(0xFFB91C1C), fontSize: 13)),
          ),
        const SizedBox(height: 8),
        const Text(
          'Your file is stored online and the QR opens a link to it. Max 50 MB.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _section(String title, IconData icon, Widget child,
      {bool open = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: open,
          maintainState: true,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          collapsedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.soft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          title: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.deep)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [child],
        ),
      ),
    );
  }

  Widget _preview(String data, {double qrSize = 232}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (data.isEmpty)
            Container(
              width: qrSize,
              height: qrSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Text('Fill in the details\nto see your QR',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black45)),
            )
          else ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: StyledQr(
                  data: data,
                  size: qrSize,
                  style: style,
                  logo: logo,
                  logoClearBg: logoClearBg,
                ),
              ),
            ),
            const SizedBox(height: 14),
            QrQualityBadge(warnings: _warnings(data)),
            const SizedBox(height: 14),
            ExportBar(
              name: '${widget.type.label} QR',
              render: () => renderStyledPng(
                data: data,
                style: style,
                logo: logo,
                logoClearBg: logoClearBg,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _save(String data) async {
    final title = TextEditingController();
    final purpose = TextEditingController();
    final recipient = TextEditingController();

    InputDecoration deco(String label) => InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.bg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        );

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Save to Library',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
                controller: title,
                decoration: deco('Title (e.g. College Project PDF)')),
            const SizedBox(height: 12),
            TextField(
                controller: purpose, decoration: deco('Purpose (optional)')),
            const SizedBox(height: 12),
            TextField(
                controller: recipient,
                decoration: deco('Made for whom? (optional)')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    await QrStore.add(SavedQr(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.text.trim().isEmpty
          ? '${widget.type.label} QR'
          : title.text.trim(),
      type: widget.type.label,
      payload: data,
      purpose: purpose.text.trim(),
      recipient: recipient.text.trim(),
      fg: style.fg.value,
      bg: style.bg.value,
      round: style.body == BodyShape.dots,
      roundEyes: style.frame == FrameShape.circle,
      logo: logo == null ? null : base64Encode(logo!),
      logoClearBg: logoClearBg,
      style: style.toJson(),
      favorite: false,
      createdAt: DateTime.now(),
    ));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to My QR Library')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = payload;
    final type = widget.type;
    final kind = uploadKinds[type.label];
    final wide = isWide(context);

    final noteBox = type.note == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.soft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(type.note!,
                        style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          );

    final sections = <Widget>[
      noteBox,
      _section(
        'Enter content',
        Icons.edit_outlined,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (kind != null) ...[
              _chipRow(
                'Source',
                const ['Link', 'Upload file'],
                uploadMode ? 'Upload file' : 'Link',
                (o) => _setMode(o == 'Upload file'),
              ),
              const SizedBox(height: 12),
            ],
            for (final f in type.fields)
              if (_visible(f) && !(kind != null && uploadMode))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _field(f),
                ),
            if (kind != null && uploadMode) _uploadPanel(kind),
          ],
        ),
        open: true,
      ),
      _section(
        'Templates',
        Icons.auto_awesome_outlined,
        TemplatesSection(onPick: (s) => setState(() => style = s)),
      ),
      _section(
        'Set colors',
        Icons.palette_outlined,
        ColorsSection(
            style: style, onChanged: (s) => setState(() => style = s)),
      ),
      _section(
        'Add logo image',
        Icons.image_outlined,
        LogoSection(
          logo: logo,
          clearBg: logoClearBg,
          onUpload: _pickLogo,
          onPreset: _usePreset,
          onRemove: () => setState(() => logo = null),
          onClearBg: (v) => setState(() => logoClearBg = v),
        ),
      ),
      _section(
        'Customize design',
        Icons.qr_code_2,
        ShapesSection(
            style: style, onChanged: (s) => setState(() => style = s)),
      ),
    ];

    final saveButton = FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: data.isEmpty ? null : () => _save(data),
      icon: const Icon(Icons.bookmark_add_outlined),
      label: const Text('Save to Library'),
    );

    // Website: left mein form, right mein QR (scroll karne par bhi dikhta rahega)
    final Widget body = wide
        ? Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: sections,
                  ),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 400,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _preview(data, qrSize: 300),
                        const SizedBox(height: 16),
                        SizedBox(width: double.infinity, child: saveButton),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        // Phone: pehle jaisa, ek hi column
        : ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              _preview(data),
              const SizedBox(height: 16),
              ...sections,
              const SizedBox(height: 8),
              saveButton,
            ],
          );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('${type.label} QR',
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: wide ? fitWidth(body) : body,
    );
  }
}
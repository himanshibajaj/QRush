import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart';

class UploadConfig {
  static const url = supabaseUrl;
  static const key = supabaseKey;
  static const bucket = 'qr-files';

  static bool get ready =>
      url.startsWith('https://') && !key.startsWith('PASTE');
}

class UploadKind {
  final String noun;
  final FileType type;
  final List<String>? extensions;
  const UploadKind(this.noun, this.type, [this.extensions]);
}

/// Kis type mein upload option dikhana hai
const uploadKinds = <String, UploadKind>{
  'PDF': UploadKind('PDF', FileType.custom, ['pdf']),
  'MP3': UploadKind('audio file', FileType.audio),
  'Video': UploadKind('video', FileType.video),
  'Image Gallery': UploadKind('photo', FileType.image),
};

class UploadException implements Exception {
  final String message;
  UploadException(this.message);
  @override
  String toString() => message;
}

class UploadedFile {
  final String url;
  final String name;
  const UploadedFile(this.url, this.name);
}

const _maxBytes = 50 * 1024 * 1024; // Supabase free plan ki limit

String _mimeFor(String name) {
  final e = name.contains('.') ? name.split('.').last.toLowerCase() : '';
  const m = {
    'pdf': 'application/pdf',
    'mp3': 'audio/mpeg',
    'wav': 'audio/wav',
    'm4a': 'audio/mp4',
    'aac': 'audio/aac',
    'ogg': 'audio/ogg',
    'mp4': 'video/mp4',
    'mov': 'video/quicktime',
    'webm': 'video/webm',
    'mkv': 'video/x-matroska',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
  };
  return m[e] ?? 'application/octet-stream';
}

Future<UploadedFile?> pickAndUpload(UploadKind kind) async {
  if (!UploadConfig.ready) {
    throw UploadException(
        'Upload is not set up yet. Add your Supabase URL and key in lib/upload_service.dart.');
  }

  final res = await FilePicker.platform.pickFiles(
    type: kind.type,
    allowedExtensions: kind.extensions,
    withData: true,
  );
  if (res == null || res.files.isEmpty) return null;

  final f = res.files.first;
  final Uint8List? bytes = f.bytes;
  if (bytes == null) throw UploadException('Could not read this file.');
  if (bytes.length > _maxBytes) {
    throw UploadException('This file is larger than 50 MB.');
  }

  final base = UploadConfig.url.replaceAll(RegExp(r'/+$'), '');
  final clean = f.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
  final path = '${DateTime.now().millisecondsSinceEpoch}_$clean';

  final headers = <String, String>{
    'apikey': UploadConfig.key,
    'Content-Type': _mimeFor(f.name),
  };
  // Purani JWT wali key (eyJ...) ke saath Authorization bhi bhejte hain
  if (UploadConfig.key.startsWith('eyJ')) {
    headers['Authorization'] = 'Bearer ${UploadConfig.key}';
  }

  final http.Response r;
  try {
    r = await http.post(
      Uri.parse('$base/storage/v1/object/${UploadConfig.bucket}/$path'),
      headers: headers,
      body: bytes,
    );
  } catch (e) {
    throw UploadException('Could not reach the upload server. Check your internet.');
  }

  if (r.statusCode < 200 || r.statusCode >= 300) {
    throw UploadException('Upload failed (${r.statusCode}). ${r.body}');
  }

  return UploadedFile(
    '$base/storage/v1/object/public/${UploadConfig.bucket}/$path',
    f.name,
  );
}
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'saved_qr.dart';

class QrStore {
  static const _key = 'saved_qrs';

  static Future<List<SavedQr>> loadAll() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List)
        .map((e) => SavedQr.fromJson(e as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  static Future<void> _saveAll(List<SavedQr> items) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  static Future<void> add(SavedQr q) async {
    final l = await loadAll();
    l.add(q);
    await _saveAll(l);
  }

  static Future<void> update(SavedQr q) async {
    final l = await loadAll();
    final i = l.indexWhere((e) => e.id == q.id);
    if (i != -1) l[i] = q;
    await _saveAll(l);
  }

  static Future<void> delete(String id) async {
    final l = await loadAll();
    l.removeWhere((e) => e.id == id);
    await _saveAll(l);
  }
}
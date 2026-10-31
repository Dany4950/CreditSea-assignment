import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// TTL cache for NON-sensitive GET responses (e.g. loan list).
/// Never put tokens / PAN / other PII here, use SecureStorageService for secrets.
class CacheService extends GetxService {
  late final Box<String> _box;

  Future<CacheService> init() async {
    _box = await Hive.openBox<String>('api_cache');
    return this;
  }

  dynamic read(String key, Duration ttl) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final age = DateTime.now().millisecondsSinceEpoch - (m['t'] as int);
      if (age > ttl.inMilliseconds) return null;
      return m['d'];
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String key, dynamic data) => _box.put(
        key,
        jsonEncode({'t': DateTime.now().millisecondsSinceEpoch, 'd': data}),
      );

  Future<void> invalidate(String keyContains) async {
    final keys = _box.keys.where((k) => k.toString().contains(keyContains)).toList();
    await _box.deleteAll(keys);
  }

  Future<void> clear() => _box.clear();
}

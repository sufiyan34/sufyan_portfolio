import 'package:firebase_database/firebase_database.dart';

/// Thin, generic wrapper around Firebase Realtime Database.
///
/// Repositories (one per Firebase node — siteInfo, services, projects,
/// etc.) sit on top of this instead of talking to `FirebaseDatabase`
/// directly, so the data-access pattern stays consistent:
///
/// ```text
/// View -> GetX Controller -> Repository -> RealtimeDbService
/// ```
class RealtimeDbService {
  RealtimeDbService._();
  static final RealtimeDbService instance = RealtimeDbService._();

  final DatabaseReference _root = FirebaseDatabase.instance.ref();

  DatabaseReference ref(String path) => _root.child(path);

  /// One-time read of a single node. Returns null if the node doesn't exist.
  Future<Map<dynamic, dynamic>?> readOnce(String path) async {
    final snapshot = await ref(path).get();
    if (!snapshot.exists || snapshot.value == null) return null;
    return Map<dynamic, dynamic>.from(snapshot.value as Map);
  }

  /// One-time read of a collection node (a map of child-key -> child-map).
  Future<Map<String, Map<dynamic, dynamic>>> readCollectionOnce(
    String path,
  ) async {
    final snapshot = await ref(path).get();
    if (!snapshot.exists || snapshot.value == null) return {};
    final raw = Map<dynamic, dynamic>.from(snapshot.value as Map);
    return raw.map(
      (key, value) =>
          MapEntry(key.toString(), Map<dynamic, dynamic>.from(value as Map)),
    );
  }

  /// Live stream of a single node — use for content that should update the
  /// UI in real time (e.g. availability badge). Prefer [readOnce] for
  /// content that only needs to load once, per the "don't maintain
  /// unnecessary real-time listeners" rule in the design spec.
  Stream<Map<dynamic, dynamic>?> watch(String path) {
    return ref(path).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return null;
      return Map<dynamic, dynamic>.from(value as Map);
    });
  }

  /// Live stream of a collection node.
  Stream<Map<String, Map<dynamic, dynamic>>> watchCollection(String path) {
    return ref(path).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return {};
      final raw = Map<dynamic, dynamic>.from(value as Map);
      return raw.map(
        (key, v) =>
            MapEntry(key.toString(), Map<dynamic, dynamic>.from(v as Map)),
      );
    });
  }

  /// Overwrites the node at [path] entirely.
  Future<void> set(String path, Map<String, dynamic> data) =>
      ref(path).set(data);

  /// Merges [data] into the existing node at [path] without touching
  /// sibling keys.
  Future<void> update(String path, Map<String, dynamic> data) =>
      ref(path).update(data);

  /// Appends a new child under [path] with an auto-generated key and
  /// returns that key.
  Future<String> push(String path, Map<String, dynamic> data) async {
    final newRef = ref(path).push();
    await newRef.set(data);
    return newRef.key!;
  }

  Future<void> remove(String path) => ref(path).remove();

  /// Server-side timestamp placeholder — use for createdAt/updatedAt so the
  /// value is trusted rather than the client clock.
  Object get serverTimestamp => ServerValue.timestamp;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NutritionistTipsAccessService {
  static const String _seenTipsKey = 'seen_nutritionist_tips';

  static Future<void> markTipAsViewed(String tipId) async {
    if (tipId.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final seenIds = (prefs.getStringList(_seenTipsKey) ?? <String>[]).toSet();
    seenIds.add(tipId);

    await prefs.setStringList(_seenTipsKey, seenIds.toList()..sort());
  }

  static Future<Set<String>> getSeenTips() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_seenTipsKey) ?? <String>[]).toSet();
  }

  static Future<bool> canAccessGames({required List<String> allTipIds}) async {
    if (allTipIds.isEmpty) {
      return false;
    }

    final seenTips = await getSeenTips();
    return allTipIds.every((tipId) => seenTips.contains(tipId));
  }

  static Future<List<String>> getAllTipIds() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('nutritionist_tips')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }
}

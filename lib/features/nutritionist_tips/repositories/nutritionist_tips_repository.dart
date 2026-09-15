
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nutritionist_tips_model.dart';

class NutritionistTipsRepository {
  final FirebaseFirestore _firestore;

  NutritionistTipsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  List<NutritionistTipsModel> _mapTips(QuerySnapshot<Object?> snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return NutritionistTipsModel.fromMap(data, doc.id);
    }).toList();
  }

  Future<List<NutritionistTipsModel>> _safeQueryList(
    Future<QuerySnapshot<Object?>> Function() queryBuilder,
  ) async {
    try {
      final snapshot = await queryBuilder();
      return _mapTips(snapshot);
    } catch (_) {
      return [];
    }
  }

  Future<List<NutritionistTipsModel>> getTips() async {
    return _safeQueryList(
      () => _firestore.collection('nutritionist_tips').get(),
    );
  }

  Future<List<NutritionistTipsModel>> getTipsByContext(String contextId) async {
    return _safeQueryList(
      () => _firestore
          .collection('nutritionist_tips')
          .where('contextId', isEqualTo: contextId)
          .get(),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/theory_model.dart';

class TheoryRepository {
  final FirebaseFirestore _firestore;

  TheoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<TheoryModel?> getTheoryById(String theoryId) async {
    if (theoryId.isEmpty) return null;

    try {
      final doc = await _firestore
          .collection('theory')
          .doc(theoryId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      final theory = TheoryModel.fromMap(data, doc.id);

      // 🔥 REMOVIDA A BUSCA DE ALIMENTOS
      // Os alimentos serão buscados em outra página/controller

      return theory;
      
    } catch (e) {
      return null;
    }
  }

  // 🔥 MÉTODO REMOVIDO: _getAllFoods()
}

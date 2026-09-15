import 'package:flutter_test/flutter_test.dart';
import 'package:glicoeduca/features/duel/models/duel_model.dart';

void main() {
  test('DuelModel reads the correct answer from Firestore fallback fields', () {
    final duel = DuelModel.fromMap(
      {
        'contextId': 'breakfast',
        'foodAId': 'apple',
        'foodBId': 'nutrition_tip_01',
        'correctAnswer': 'Batata-doce + proteína',
      },
      'duel_1',
    );

    expect(duel.contextId, 'breakfast');
    expect(duel.foodAId, 'apple');
    expect(duel.foodBId, 'nutrition_tip_01');
    expect(duel.correctAnswerId, '');
    expect(duel.correctAnswerLabel, 'Batata-doce + proteína');
  });
}

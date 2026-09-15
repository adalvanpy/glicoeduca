class ContextModel {
  final String id;
  final String name;
  final int order;

  ContextModel({
    required this.id,
    required this.name,
    required this.order,
  });

  static String normalizeDisplayName(String? rawName, String documentId) {
    final id = (documentId.isNotEmpty ? documentId : rawName ?? '').trim().toLowerCase();
    final fallback = (rawName ?? '').trim();

    final names = {
      'breakfast': 'Café da manhã',
      'morning_snack': 'Lanche da manhã',
      'lunch': 'Almoço',
      'afternoon_snack': 'Lanche da tarde',
      'evening_snack': 'Ceia',
      'pre_workout': 'Pré atividade física',
      'post_workout': 'Pós atividade física',
      'dinner': 'Jantar',
    };

    if (names.containsKey(id)) {
      return names[id]!;
    }

    if (fallback.isNotEmpty) {
      return fallback;
    }

    return id.isNotEmpty ? id.replaceAll('_', ' ') : 'Contexto';
  }

  factory ContextModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    final rawName = map['name'];

    return ContextModel(
      id: documentId,
      name: normalizeDisplayName(rawName is String ? rawName : '', documentId),
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'order': order,
    };
  }
}


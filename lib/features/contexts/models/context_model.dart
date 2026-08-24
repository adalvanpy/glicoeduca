class ContextModel {
  final String id;
  final String name;
  final int order;

  ContextModel({
    required this.id,
    required this.name,
    required this.order,
  });

  factory ContextModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return ContextModel(
      id: documentId,
      name: map['name'] ?? '',
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

import '../../foods/models/food_model.dart';

class TheoryModel {
  final String id;
  final String title;
  final String description;
  final String conceito;
  final String content;
  final String image;
  final int order;
  final String title2;
  final String contentTitle2;
  final String title3;
  final String contentTitle3;
  final String title4;
  final String contentTitle4;
  final String title5;
  final String contentTitle5;
  final List<FoodModel> foods;

  TheoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.conceito,
    required this.content,
    required this.image,
    required this.order,
    required this.title2,
    required this.contentTitle2,
    required this.title3,
    required this.contentTitle3,
    required this.title4,
    required this.contentTitle4,
    required this.title5,
    required this.contentTitle5,
    this.foods = const [], // ← VALOR PADRÃO
  });

  factory TheoryModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return TheoryModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      conceito: map['conceito'] ?? '',
      content: map['content'] ?? '',
      image: map['image'] ?? '',
      order: map['order'] ?? 0,
      title2: map['title2'] ?? '',
      contentTitle2: map['contentTitle2'] ?? '',
      title3: map['title3'] ?? '',
      contentTitle3: map['contentTitle3'] ?? '',
      title4: map['title4'] ?? '',
      contentTitle4: map['contentTitle4'] ?? '',
      title5: map['title5'] ?? '',
      contentTitle5: map['contentTitle5'] ?? '',
      foods: [], // INICIA VAZIO
    );
  }

  // Método para criar uma cópia com os alimentos
  TheoryModel copyWith({List<FoodModel>? foods}) {
    return TheoryModel(
      id: id,
      title: title,
      description: description,
      conceito: conceito,
      content: content,
      image: image,
      order: order,
      title2: title2,
      contentTitle2: contentTitle2,
      title3: title3,
      contentTitle3: contentTitle3,
      title4: title4,
      contentTitle4: contentTitle4,
      title5: title5,
      contentTitle5: contentTitle5,
      foods: foods ?? this.foods,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'conceito': conceito,
      'content': content,
      'image': image,
      'order': order,
      'title2': title2,
      'contentTitle2': contentTitle2,
      'title3': title3,
      'contentTitle3': contentTitle3,
      'title4': title4,
      'contentTitle4': contentTitle4,
      'title5': title5,
      'contentTitle5': contentTitle5,
    };
  }
}

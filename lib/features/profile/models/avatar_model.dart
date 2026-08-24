class AvatarModel {
  final String id;
  final String image;
  final String sex;

  AvatarModel({
    required this.id,
    required this.image,
    required this.sex,
  });

  factory AvatarModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AvatarModel(
      id: documentId,
      image: map['image'] ?? '',
      sex: map['sex'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'sex': sex,
    };
  }
}
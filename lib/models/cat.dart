class Cat {
  final String imageUrl;
  final String breed;
  final String description;

  Cat({
    required this.imageUrl,
    required this.breed,
    required this.description,
  });

  factory Cat.fromJson(Map<String, dynamic> json) {
    final breedInfo =
        json['breeds']?.isNotEmpty == true ? json['breeds'][0] : null;
    return Cat(
      imageUrl: json['url'] ?? '',
      breed: breedInfo != null ? breedInfo['name'] : 'Неизвестно',
      description:
          breedInfo != null ? breedInfo['description'] : 'Описание недоступно',
    );
  }
}

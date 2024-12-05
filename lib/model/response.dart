//Tidak terpakai

class Activity {
  final String id;
  final String name;
  final String shortDescription;
  final String rating;
  final String price;
  final String imageUrl;

  Activity({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.rating,
    required this.price,
    required this.imageUrl,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      rating: json['rating'] ?? '0.0',
      price: json['price']['amount'] ?? '0.0',
      imageUrl: json['pictures'] != null && json['pictures'].isNotEmpty
          ? json['pictures'][0]
          : '',
    );
  }
}

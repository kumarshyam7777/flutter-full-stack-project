class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String category;
  final String thumbnail;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
        rating: (json['rating'] ?? 0).toDouble(),
        stock: json['stock'] ?? 0,
        brand: json['brand'] ?? 'Unknown',
        category: json['category'] ?? '',
        thumbnail: json['thumbnail'] ?? '',
        images: List<String>.from(json['images'] ?? []),
      );

  double get discountedPrice => price * (1 - discountPercentage / 100);
}

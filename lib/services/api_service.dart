import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../utils/logger.dart';

class ApiService {
  static const String _base = 'https://dummyjson.com';
  
  // Cache storage
  static final Map<String, List<Product>> _cache = {};
  static List<String>? _categoriesCache;
  static bool _lastFetchFailed = false;

  static bool get isOffline => _lastFetchFailed;

  static Future<List<Product>> fetchProducts({int skip = 0, int limit = 30}) async {
    final cacheKey = 'all_${skip}_$limit';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    try {
      logger.i('API: Fetching default products (skip=$skip, limit=$limit)');
      final res = await http.get(Uri.parse('$_base/products?limit=$limit&skip=$skip')).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        _lastFetchFailed = false;
        final data = jsonDecode(res.body);
        final products = (data['products'] as List).map((e) => Product.fromJson(e)).toList();
        _cache[cacheKey] = products;
        return products;
      }
    } catch (e) {
      logger.e('API Error: $e. Falling back to MOCK data.');
      _lastFetchFailed = true;
    }
    return _mockProducts;
  }

  static Future<List<String>> fetchCategories() async {
    if (_categoriesCache != null) return _categoriesCache!;

    try {
      logger.i('API: Fetching category list');
      final res = await http.get(Uri.parse('$_base/products/category-list')).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        _lastFetchFailed = false;
        final data = jsonDecode(res.body) as List;
        _categoriesCache = data.cast<String>();
        return _categoriesCache!;
      }
    } catch (e) {
      logger.e('API Error: $e. Falling back to MOCK categories.');
      _lastFetchFailed = true;
    }
    return _mockCategories;
  }

  static Future<List<Product>> fetchByCategory(String category) async {
    if (_cache.containsKey(category)) return _cache[category]!;

    try {
      logger.i('API: Fetching products for category: $category');
      final res = await http.get(Uri.parse('$_base/products/category/$category')).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        _lastFetchFailed = false;
        final data = jsonDecode(res.body);
        final products = (data['products'] as List).map((e) => Product.fromJson(e)).toList();
        _cache[category] = products;
        return products;
      }
    } catch (e) {
      logger.e('API Error: $e. Falling back to MOCK products for $category.');
      _lastFetchFailed = true;
    }
    
    // Simple filter of mock products by category
    final fallback = _mockProducts.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
    return fallback.isNotEmpty ? fallback : _mockProducts.take(10).toList();
  }

  static Future<List<Product>> searchProducts(String query) async {
    try {
      logger.i('API: Searching for: $query');
      final res = await http.get(Uri.parse('$_base/products/search?q=$query')).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['products'] as List).map((e) => Product.fromJson(e)).toList();
      }
    } catch (e) {
      logger.e('Search failure: $e. Using mock search.');
    }
    return _mockProducts.where((p) => p.title.toLowerCase().contains(query.toLowerCase())).toList();
  }

  static void clearCache() => _cache.clear();

  // --- MOCK DATA ---
  static final List<String> _mockCategories = ['beauty', 'fragrances', 'furniture', 'groceries'];
  
  static final List<Product> _mockProducts = [
    Product(
      id: 1,
      title: 'Essence Mascara Lash Princess',
      description: 'The Essence Mascara Lash Princess is a popular mascara known for its volume.',
      price: 9.99,
      discountPercentage: 7.17,
      rating: 4.94,
      stock: 5,
      brand: 'Essence',
      category: 'beauty',
      thumbnail: 'https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/thumbnail.jpg',
      images: [],
    ),
    Product(
      id: 2,
      title: 'Eyeshadow Palette with Mirror',
      description: 'The Eyeshadow Palette with Mirror offers a versatile range of colors for creating stunning eye looks.',
      price: 19.99,
      discountPercentage: 5.5,
      rating: 3.28,
      stock: 44,
      brand: 'Glamour Beauty',
      category: 'beauty',
      thumbnail: 'https://cdn.dummyjson.com/products/images/beauty/Eyeshadow%20Palette%20with%20Mirror/thumbnail.jpg',
      images: [],
    ),
    Product(
      id: 3,
      title: 'Calvin Klein CK One',
      description: 'CK One by Calvin Klein is a classic unisex fragrance with notes of citrus and green tea.',
      price: 49.99,
      discountPercentage: 0.32,
      rating: 4.85,
      stock: 17,
      brand: 'Calvin Klein',
      category: 'fragrances',
      thumbnail: 'https://cdn.dummyjson.com/products/images/fragrances/Calvin%20Klein%20CK%20One/thumbnail.jpg',
      images: [],
    ),
    Product(
      id: 4,
      title: 'Annibale Colombo Bed',
      description: 'The Annibale Colombo Bed is a luxurious and elegant bed frame, crafted with high-quality materials.',
      price: 1899.99,
      discountPercentage: 0.0,
      rating: 4.14,
      stock: 47,
      brand: 'Annibale Colombo',
      category: 'furniture',
      thumbnail: 'https://cdn.dummyjson.com/products/images/furniture/Annibale%20Colombo%20Bed/thumbnail.jpg',
      images: [],
    ),
  ];
}

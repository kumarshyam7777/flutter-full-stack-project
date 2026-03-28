import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartState extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get count => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get total =>
      _items.values.fold(0, (sum, item) => sum + item.product.discountedPrice * item.quantity);

  void add(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void remove(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void decrement(int productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items[productId]!.quantity--;
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  bool contains(int productId) => _items.containsKey(productId);
  int quantityOf(int productId) => _items[productId]?.quantity ?? 0;

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

// Global cart state instance
final cartState = CartState();

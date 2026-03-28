import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _imgIdx = 0;
  int _qty = 1;
  bool _inCart = false;

  @override
  void initState() {
    super.initState();
    _inCart = cartState.contains(widget.product.id);
    cartState.addListener(_onCart);
  }

  void _onCart() {
    if (mounted) {
      setState(() => _inCart = cartState.contains(widget.product.id));
    }
  }

  @override
  void dispose() {
    cartState.removeListener(_onCart);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final images = p.images.isNotEmpty ? p.images : [p.thumbnail];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: AppTheme.bg,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.card.withOpacity(0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.divider),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 16),
              ),
            ),
            actions: [
              CartBadge(
                count: cartState.count,
                onTap: () => Navigator.push(context, slideRoute(const CartScreen())),
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _imgIdx = i),
                    itemBuilder: (_, i) => NetworkImg(url: images[i]),
                  ),
                  if (p.discountPercentage > 0)
                    Positioned(
                      top: 60,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppTheme.error, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          '${p.discountPercentage.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1),
                        ),
                      ),
                    ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _imgIdx ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == _imgIdx ? AppTheme.accent : Colors.white38,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                        ),
                        child: Text(
                          p.brand.toUpperCase(),
                          style: const TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2),
                        ),
                      ),
                      const Spacer(),
                      StarRating(rating: p.rating),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    p.title,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w700, height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.category.isNotEmpty ? p.category[0].toUpperCase() + p.category.substring(1) : '',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, letterSpacing: 1),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${p.discountedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppTheme.accent, fontSize: 32, fontWeight: FontWeight.w900),
                      ),
                      if (p.discountPercentage > 0) ...[
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '\$${p.price.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16, decoration: TextDecoration.lineThrough),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  StockIndicator(stock: p.stock),
                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.divider),
                  const SizedBox(height: 20),
                  const Text('Description', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(
                    p.description,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.7),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      QtySelector(
                        qty: _qty,
                        onIncrement: () => setState(() => _qty++),
                        onDecrement: () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            for (var i = 0; i < _qty; i++) {
                              cartState.add(p);
                            }
                            HapticFeedback.mediumImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppTheme.card,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: AppTheme.success),
                                    const SizedBox(width: 10),
                                    const Text('Added to cart!', style: TextStyle(color: AppTheme.textPrimary)),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.accentLight]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: AppTheme.accent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _inCart ? 'Add More' : 'Add to Cart',
                                style: const TextStyle(color: AppTheme.bg, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

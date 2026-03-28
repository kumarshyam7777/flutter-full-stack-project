import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';
import '../screens/product_detail_screen.dart';

// ─── NAVIGATION HELPER ────────────────────────────────────────────────────────
PageRoute slideRoute(Widget page) {
  return PageRouteBuilder(
    // ignore: unnecessary_underscores
    pageBuilder: (_, __, ___) => page,
    // ignore: unnecessary_underscores
    transitionsBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

// ─── NETWORK IMAGE ───────────────────────────────────────────────────────────
class NetworkImg extends StatelessWidget {
  final String url;
  const NetworkImg({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => Container(
        color: AppTheme.card,
        child: const Icon(Icons.image_not_supported_rounded, color: AppTheme.textSecondary),
      ),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppTheme.card,
          child: const Center(
            child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2),
          ),
        );
      },
    );
  }
}

// ─── STAR RATING ─────────────────────────────────────────────────────────────
class StarRating extends StatelessWidget {
  final double rating;
  const StarRating({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, color: AppTheme.accent, size: 18),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ─── STOCK INDICATOR ─────────────────────────────────────────────────────────
class StockIndicator extends StatelessWidget {
  final int stock;
  const StockIndicator({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final low = stock < 10;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: low ? AppTheme.error : AppTheme.success,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          low ? 'Only $stock left!' : '$stock in stock',
          style: TextStyle(
            color: low ? AppTheme.error : AppTheme.success,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── QTY SELECTOR ────────────────────────────────────────────────────────────
class QtySelector extends StatelessWidget {
  final int qty;
  final VoidCallback onIncrement, onDecrement;
  const QtySelector(
      {super.key, required this.qty,
      required this.onIncrement,
      required this.onDecrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_rounded, color: AppTheme.textSecondary, size: 20),
          ),
          Text(
            '$qty',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add_rounded, color: AppTheme.accent, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─── CART BADGE ──────────────────────────────────────────────────────────────
class CartBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const CartBadge({super.key, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.divider),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.textPrimary, size: 20),
          ),
          if (count > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: AppTheme.bg,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── ADD CART BTN ────────────────────────────────────────────────────────────
class AddCartBtn extends StatelessWidget {
  final bool inCart;
  final VoidCallback onTap;
  const AddCartBtn({super.key, required this.inCart, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: inCart ? AppTheme.accent : AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: inCart ? AppTheme.accent : AppTheme.divider,
          ),
        ),
        child: Icon(
          inCart ? Icons.check_rounded : Icons.add_rounded,
          color: inCart ? AppTheme.bg : AppTheme.textSecondary,
          size: 18,
        ),
      ),
    );
  }
}

// ─── PRODUCT CARD ────────────────────────────────────────────────────────────
class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;
  bool _inCart = false;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));
    _inCart = cartState.contains(widget.product.id);
    cartState.addListener(_onCart);
  }

  void _onCart() {
    final newState = cartState.contains(widget.product.id);
    if (newState != _inCart && mounted) setState(() => _inCart = newState);
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    cartState.removeListener(_onCart);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) {
        _scaleCtrl.reverse();
        Navigator.push(context, slideRoute(ProductDetailScreen(product: widget.product)));
      },
      onTapCancel: () => _scaleCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    children: [
                      NetworkImg(url: widget.product.thumbnail),
                      if (widget.product.discountPercentage > 0)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${widget.product.discountPercentage.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.brand,
                        style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.product.title,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.product.discountPercentage > 0)
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '\$${widget.product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, decoration: TextDecoration.lineThrough),
                                    ),
                                  ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '\$${widget.product.discountedPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(color: AppTheme.accent, fontSize: 15, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          AddCartBtn(
                            inCart: _inCart,
                            onTap: () {
                              cartState.add(widget.product);
                              HapticFeedback.lightImpact();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

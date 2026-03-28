import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../state/cart_state.dart';
import '../models/cart_item.dart';
import '../widgets/shared_widgets.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override void initState() { super.initState(); cartState.addListener(_refresh); }
  void _refresh() { if (mounted) setState(() {}); }
  @override void dispose() { cartState.removeListener(_refresh); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final items = cartState.items;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.card, shape: BoxShape.circle, border: Border.all(color: AppTheme.divider)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 16),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Cart', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
            Text('${items.length} item${items.length == 1 ? '' : 's'}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppTheme.card,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Clear cart?', style: TextStyle(color: AppTheme.textPrimary)),
                  content: const Text('Remove all items from your cart.', style: TextStyle(color: AppTheme.textSecondary)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
                    TextButton(onPressed: () { cartState.clear(); Navigator.pop(context); }, child: const Text('Clear', style: TextStyle(color: AppTheme.error))),
                  ],
                ),
              ),
              child: const Text('Clear', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: items.isEmpty ? EmptyCart(onShop: () => Navigator.pop(context)) : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              itemCount: items.length,
              itemBuilder: (_, i) => CartItemCard(item: items[i]),
            ),
          ),
          CheckoutBar(total: cartState.total),
        ],
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.divider)),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: SizedBox(width: 80, height: 80, child: NetworkImg(url: p.thumbnail))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.brand, style: const TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(p.title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text('\$${p.discountedPrice.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.accent, fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              GestureDetector(onTap: () => cartState.remove(p.id), child: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 20)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _qtyBtn(Icons.remove_rounded, AppTheme.textSecondary, () => cartState.decrement(p.id)),
                    Text('${item.quantity}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                    _qtyBtn(Icons.add_rounded, AppTheme.accent, () => cartState.add(p)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, color: color, size: 14)),
  );
}

class CheckoutBar extends StatelessWidget {
  final double total;
  const CheckoutBar({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(color: AppTheme.surface, border: Border(top: BorderSide(color: AppTheme.divider))),
      child: Column(
        children: [
          _buildRow('Subtotal', '\$${total.toStringAsFixed(2)}', const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _buildRow('Shipping', 'Free', const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.divider),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.accent, fontSize: 22, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(onTap: () => _checkout(context), child: _btn('Checkout Now', true)),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String val, TextStyle style) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)), Text(val, style: style)],
  );

  Widget _btn(String text, bool shadow) => Container(
    width: double.infinity, height: shadow ? 56 : 48,
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.accentLight]),
      borderRadius: BorderRadius.circular(shadow ? 18 : 14),
      boxShadow: shadow ? [BoxShadow(color: AppTheme.accent.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 10))] : null,
    ),
    child: Center(child: Text(text, style: TextStyle(color: AppTheme.bg, fontSize: shadow ? 17 : 14, fontWeight: FontWeight.w800, letterSpacing: shadow ? 0.5 : 0))),
  );

  void _checkout(BuildContext context) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: AppTheme.success, size: 40),
            ),
            const SizedBox(height: 16),
            const Text('Order Placed!', style: TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Thank you for your purchase. Your order is being processed.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () { cartState.clear(); Navigator.pop(context); Navigator.pop(context); },
              child: _btn('Continue Shopping', false),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyCart extends StatelessWidget {
  final VoidCallback onShop;
  const EmptyCart({super.key, required this.onShop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: AppTheme.card, shape: BoxShape.circle, border: Border.all(color: AppTheme.divider)),
            child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.textSecondary, size: 48),
          ),
          const SizedBox(height: 24),
          const Text('Your cart is empty', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Add items to get started', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: onShop,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.accentLight]), borderRadius: BorderRadius.circular(16)),
              child: const Text('Start Shopping', style: TextStyle(color: AppTheme.bg, fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

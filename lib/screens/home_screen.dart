import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../utils/logger.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Product> _products = [];
  List<String> _categories = [];
  String _selectedCategory = 'all';
  bool _loading = true;
  bool _searching = false;
  final TextEditingController _searchCtrl = TextEditingController();
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _loadData();
    cartState.addListener(_onCartChanged);
  }

  void _onCartChanged() {
    if (mounted) setState(() => _cartCount = cartState.count);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    cartState.removeListener(_onCartChanged);
    super.dispose();
  }

  Future<void> _loadData() async {
    // Only show full loading if results aren't cached
    if (_products.isEmpty) setState(() => _loading = true);
    
    try {
      // Don't refetch categories if we already have them
      if (_categories.isEmpty) {
        final cats = await ApiService.fetchCategories();
        if (mounted) setState(() => _categories = ['all', ...cats]);
      }
      
      final products = await ApiService.fetchProducts(limit: 30);
      if (mounted) {
        setState(() {
          _products = products;
          _loading = false;
        });
        _fadeCtrl.forward(from: 0.0);
      }
    } catch (e) {
      logger.e('Load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectCategory(String cat) async {
    if (_selectedCategory == cat) return;
    
    setState(() {
      _selectedCategory = cat;
      // ONLY show loading spinner if it's NOT in the cache
      // (This logic resides in ApiService now, but we check here to avoid flicker)
      _loading = false; // We default to false and then maybe true if we want to show a small indicator
    });

    _fadeCtrl.reset();
    
    try {
      final products = cat == 'all'
          ? await ApiService.fetchProducts(limit: 30)
          : await ApiService.fetchByCategory(cat);
          
      if (mounted) {
        setState(() {
          _products = products;
          _loading = false;
        });
        _fadeCtrl.forward();
      }
    } catch (e) {
      logger.e('Category error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      _loadData();
      return;
    }
    setState(() => _loading = true);
    _fadeCtrl.reset();
    try {
      _products = await ApiService.searchProducts(query);
    } catch (e) {
      logger.e('Search error: $e');
    }
    if (mounted) {
      setState(() => _loading = false);
      _fadeCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategories(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2),
                    )
                  : FadeTransition(
                      opacity: _fadeAnim,
                      child: _buildGrid(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('LUXE', style: TextStyle(color: AppTheme.accent, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 8)),
                    if (ApiService.isOffline) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _loadData,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.error.withOpacity(0.2))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.wifi_off_rounded, color: AppTheme.error, size: 12),
                              SizedBox(width: 4),
                              Text('OFFLINE', style: TextStyle(color: AppTheme.error, fontSize: 9, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const Text('Premium Shopping', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, letterSpacing: 2)),
              ],
            ),
          ),
          CartBadge(count: _cartCount, onTap: () => Navigator.push(context, slideRoute(const CartScreen()))),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.divider)),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: AppTheme.textSecondary),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: _search,
                onChanged: (v) => setState(() => _searching = v.isNotEmpty),
              ),
            ),
            if (_searching)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  setState(() => _searching = false);
                  _loadData();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final selected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => _selectCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppTheme.accent : AppTheme.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? AppTheme.accent : AppTheme.divider),
              ),
              child: Text(
                cat == 'all' ? 'All' : cat[0].toUpperCase() + cat.substring(1),
                style: TextStyle(
                  color: selected ? AppTheme.bg : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid() {
    if (_products.isEmpty) return const Center(child: Text('No products found', style: TextStyle(color: AppTheme.textSecondary)));
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 14, mainAxisSpacing: 14),
      itemCount: _products.length,
      itemBuilder: (_, i) => ProductCard(product: _products[i]),
    );
  }
}

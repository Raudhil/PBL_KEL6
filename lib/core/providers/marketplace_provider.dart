import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';

// Selected category provider
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// Orders history provider
final ordersHistoryProvider = StateProvider<List<Order>>(
  (ref) => [
    // Dummy orders for demonstration
    Order(
      id: 'ORD001',
      items: [],
      totalAmount: 50000,
      paymentMethod: 'COD',
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      status: OrderStatus.delivered,
      deliveryAddress: 'Jl. Mawar No. 123, RT 01/RW 05',
    ),
    Order(
      id: 'ORD002',
      items: [],
      totalAmount: 35000,
      paymentMethod: 'QRIS',
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.processing,
      deliveryAddress: 'Jl. Melati No. 45, RT 02/RW 03',
    ),
  ],
);

// Dummy products provider (filtered by category)
final productsProvider = Provider<List<Product>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);

  final allProducts = [
    Product(
      id: '1',
      name: 'Kentang Organik',
      price: 15000,
      category: 'Kentang',
      seller: 'Pak Budi',
      description:
          'Kentang organik segar dari kebun lokal, tanpa pestisida. Cocok untuk berbagai masakan.',
      stock: 50,
      imageUrl: '🥔',
      rating: 4.8,
    ),
    Product(
      id: '2',
      name: 'Kentang Premium',
      price: 20000,
      category: 'Kentang',
      seller: 'Bu Ani',
      description:
          'Kentang premium kualitas terbaik, ukuran besar dan seragam.',
      stock: 30,
      imageUrl: '🥔',
      rating: 4.9,
    ),
    Product(
      id: '3',
      name: 'Wortel Segar',
      price: 12000,
      category: 'Wortel',
      seller: 'Pak Joko',
      description: 'Wortel segar pilihan dengan kandungan vitamin A tinggi.',
      stock: 40,
      imageUrl: '🥕',
      rating: 4.6,
    ),
    Product(
      id: '4',
      name: 'Wortel Organik',
      price: 18000,
      category: 'Wortel',
      seller: 'Bu Siti',
      description: 'Wortel organik bebas pestisida, aman untuk keluarga.',
      stock: 25,
      imageUrl: '🥕',
      rating: 4.7,
    ),
    Product(
      id: '5',
      name: 'Tomat Merah',
      price: 10000,
      category: 'Tomat',
      seller: 'Pak Ahmad',
      description: 'Tomat merah segar, cocok untuk masakan dan jus.',
      stock: 60,
      imageUrl: '🍅',
      rating: 4.5,
    ),
    Product(
      id: '6',
      name: 'Tomat Cherry',
      price: 25000,
      category: 'Tomat',
      seller: 'Bu Rina',
      description: 'Tomat cherry manis, perfect untuk salad.',
      stock: 20,
      imageUrl: '🍅',
      rating: 4.9,
    ),
  ];

  if (selectedCategory == 'All') {
    return allProducts;
  }

  return allProducts.where((p) => p.category == selectedCategory).toList();
});

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered products based on search
final filteredProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  if (query.isEmpty) return products;

  return products
      .where(
        (p) =>
            p.name.toLowerCase().contains(query) ||
            p.seller.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query),
      )
      .toList();
});

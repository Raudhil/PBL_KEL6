class Product {
  final String id;
  final String name;
  final int price;
  final String category;
  final String seller;
  final String description;
  final int stock;
  final String imageUrl;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.seller,
    required this.description,
    required this.stock,
    required this.imageUrl,
    this.rating = 4.5,
  });

  Product copyWith({
    String? id,
    String? name,
    int? price,
    String? category,
    String? seller,
    String? description,
    int? stock,
    String? imageUrl,
    double? rating,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      seller: seller ?? this.seller,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
    );
  }
}

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  int get totalPrice => product.price * quantity;
}

class Order {
  final String id;
  final List<CartItem> items;
  final int totalAmount;
  final String paymentMethod;
  final DateTime orderDate;
  final OrderStatus status;
  final String? deliveryAddress;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.orderDate,
    required this.status,
    this.deliveryAddress,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Menunggu Konfirmasi';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.shipped:
        return 'Dikirim';
      case OrderStatus.delivered:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}

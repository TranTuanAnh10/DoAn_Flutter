class OrderData {
  final int id;
  final DateTime created;
  final double totalAmount;
  final double deliveryCharge;
  final String status;
  final List<OrderItem> items;

  OrderData({
    required this.id,
    required this.created,
    required this.totalAmount,
    required this.deliveryCharge,
    required this.status,
    required this.items,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['id'],
      created: DateTime.parse(json['created']),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryCharge: (json['deliveryCharge'] as num).toDouble(),
      status: json['status'],
      items: (json['orderItems'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

class OrderItem {
  final int id;
  final String name;
  final String photoUrl;
  final double price;
  final int count;

  OrderItem({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.price,
    required this.count,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      price: (json['price'] as num).toDouble(),
      count: json['count'],
    );
  }
}

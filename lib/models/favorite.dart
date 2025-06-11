class Favorite {
  final int id;
  final String name;
  final String? features;
  final bool available;
  final double amount;
  final String? photoUrl;

  Favorite({
    required this.id,
    required this.name,
    this.features,
    required this.available,
    required this.amount,
    this.photoUrl,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      name: json['name'],
      features: json['features'],
      available: json['available'],
      amount: (json['amount'] as num).toDouble(),
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'features': features,
      'available': available,
      'amount': amount,
      'photoUrl': photoUrl,
    };
  }
}
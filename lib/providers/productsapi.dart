class ProductApi {
  final int id;
  final String name;
  final int amount;
  final String photoUrl;

  ProductApi({
    required this.id,
    required this.name,
    required this.amount,
    required this.photoUrl,
  });

  factory ProductApi.fromJson(Map<String, dynamic> json) {
    return ProductApi(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      photoUrl: json['photoUrl'],
    );
  }
}

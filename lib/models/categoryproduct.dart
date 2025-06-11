import 'package:shop_app/providers/productsapi.dart';

class CategoryProduct {
  final String category;
  final List<ProductApi> products;

  CategoryProduct({required this.category, required this.products});

  factory CategoryProduct.fromJson(Map<String, dynamic> json) {
    var list = json['products'] as List;
    List<ProductApi> productList =
        list.map((i) => ProductApi.fromJson(i)).toList();

    return CategoryProduct(
      category: json['category'],
      products: productList,
    );
  }
}

import 'package:shop_app/models/categoryproduct.dart';

class ProductListResponse {
  final List<CategoryProduct> categoryProducts;

  ProductListResponse({required this.categoryProducts});

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    var list = json['categoryProducts'] as List;
    List<CategoryProduct> categoryProductList = list.map((i) => CategoryProduct.fromJson(i)).toList();

    return ProductListResponse(
      categoryProducts: categoryProductList,
    );
  }
}
// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop_app/providers/constants.dart';
import '../models/product_data.dart';

class ProductService {
  Future<ProductResponse> getProductDetail(int id) async {
    final response = await http.get(
      Uri.parse('${Constant.baseUrl}/api/Product/$id'),
      headers: {'accept': '*/*'},
    );

    if (response.statusCode == 200) {
      return ProductResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product');
    }
  }

  // Hàm để lấy ID của variant tương ứng khi người dùng chọn
  int? getTargetVariant(
      String name,
      String value,
      List<ProductVariant> variants,
      Map<String, ProductDetail> products,
      ) {
    // Tìm sản phẩm phù hợp với các thuộc tính đã chọn
    for (var product in products.values) {
      bool matches = true;
      for (var variant in variants) {
        final selectedValue = variant.name == name ? value : variant.selected;
        final property = product.properties
            .firstWhere((p) => p.name == variant.name, orElse: () => ProductProperty(name: '', value: ''));
        if (selectedValue != null && property.value != selectedValue) {
          matches = false;
          break;
        }
      }
      if (matches) {
        return product.id;
      }
    }
    return null;
  }
}
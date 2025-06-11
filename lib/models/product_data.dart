// lib/models/product.dart
import 'dart:convert';

class ProductResponse {
  final Map<String, ProductDetail> products;
  final List<ProductVariant> variants;

  ProductResponse({required this.products, required this.variants});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    var productsJson = json['products'] as Map<String, dynamic>;
    var products = productsJson.map(
          (key, value) => MapEntry(key, ProductDetail.fromJson(value)),
    );
    var variants = (json['variants'] as List)
        .map((v) => ProductVariant.fromJson(v))
        .toList();
    return ProductResponse(products: products, variants: variants);
  }
}

class ProductDetail {
  final int id;
  final String name;
  final String brand;
  final String model;
  final String description;
  final String features;
  final double amount;
  final int maxPerOrder;
  final String category;
  final bool available;
  final double deliveryCharge;
  final String storeName;
  final int storeItemId;
  final List<ProductPhoto> photos;
  final List<ProductProperty> properties;

  ProductDetail({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.description,
    required this.features,
    required this.amount,
    required this.maxPerOrder,
    required this.category,
    required this.available,
    required this.deliveryCharge,
    required this.storeName,
    required this.storeItemId,
    required this.photos,
    required this.properties,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      model: json['model'],
      description: json['description'],
      features: json['features'],
      amount: (json['amount'] as num).toDouble(),
      maxPerOrder: json['maxPerOrder'],
      category: json['category'],
      available: json['available'],
      deliveryCharge: (json['deliveryCharge'] as num).toDouble(),
      storeName: json['storeName'],
      storeItemId: json['storeItemId'],
      photos: (json['photos'] as List)
          .map((p) => ProductPhoto.fromJson(p))
          .toList(),
      properties: (json['properties'] as List)
          .map((p) => ProductProperty.fromJson(p))
          .toList(),
    );
  }
}

class ProductPhoto {
  final String url;
  final bool isMain;

  ProductPhoto({required this.url, required this.isMain});

  factory ProductPhoto.fromJson(Map<String, dynamic> json) {
    return ProductPhoto(url: json['url'], isMain: json['isMain']);
  }
}

class ProductProperty {
  final String name;
  final String value;

  ProductProperty({required this.name, required this.value});

  factory ProductProperty.fromJson(Map<String, dynamic> json) {
    return ProductProperty(name: json['name'], value: json['value']);
  }
}

class ProductVariant {
  final String name;
  final List<String> values;
  String? selected;

  ProductVariant({required this.name, required this.values, this.selected});

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      name: json['name'],
      values: (json['values'] as List).cast<String>(),
    );
  }
}
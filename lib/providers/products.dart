import 'product.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  String authToken;
  String userId;
  List<Product> _allItems = [];
  List<Product> _userItems = [];

  Products(this.authToken, this.userId, this._allItems, this._userItems);

  List<Product> get allItems {
    return [..._allItems];
  }

  List<Product> get userItems {
    return [..._userItems];
  }

  List<Product> get favoriteItems {
    return _allItems.where((prod) => prod.isFavorite).toList();
  }

  Product findById(String id) {
    return _allItems.firstWhere(
      (prod) => prod.id == id,
      orElse: () => Product(
        id: null,
        title: '',
        price: 0,
        description: '',
        imageUrl: '',
      ),
    );
  }

  Future<void> fetchAndSetAllData() async {
    final url = Uri.parse(
        'https://shop-app-flutter-152a-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken');
    final urlFavorite = Uri.parse(
        'https://shop-app-flutter-152a-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorite/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData.isEmpty) {
        return;
      }
      final favoriteResponse = await http.get(urlFavorite);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedData = [];
      extractedData.forEach((prodId, prodData) {
        loadedData.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            price: prodData['price'],
            isFavorite: favoriteData == null
                ? false
                : favoriteData[prodId] ??
                    false)); //favoriteData[prodId] ?? false == favoriteData[prodId] ? favoriteData[prodId] : false
      });
      _allItems = loadedData;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAndSetUserData() async {
    final filterString = 'orderBy="creatorId"&equalTo="$userId"';
    final url = Uri.parse(
        'https://shop-app-flutter-152a-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken&$filterString');
    final urlFavorite = Uri.parse(
        'https://shop-app-flutter-152a-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorite/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData.isEmpty) {
        return;
      }
      final favoriteResponse = await http.get(urlFavorite);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedData = [];
      extractedData.forEach((prodId, prodData) {
        loadedData.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            price: prodData['price'],
            isFavorite: favoriteData == null
                ? false
                : favoriteData[prodId] ??
                    false)); //favoriteData[prodId] ?? false == favoriteData[prodId] ? favoriteData[prodId] : false
      });
      _userItems = loadedData;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shop-app-flutter-152a-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _allItems.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      rethrow;
    }

    return Future.value();
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _allItems.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://shop-app-flutter-152a-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price
          }));
      _allItems[prodIndex] = newProduct;
      notifyListeners();
    } else {
      return;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://shop-app-flutter-152a-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken');
    final existingProductIndex = _allItems.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _allItems[existingProductIndex];
    _allItems.removeAt(existingProductIndex);
    notifyListeners();
    final reponse = await http.delete(url);
    if (reponse.statusCode > 400) {
      _allItems.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }
}

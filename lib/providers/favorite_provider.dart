import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/favorite.dart';
import 'constants.dart';

class FavoriteProvider with ChangeNotifier {
  List<Favorite> _favorites = [];
  bool isLoading = false;

  List<Favorite> get favorites => _favorites;

  Future<List<Favorite>> fetchFavorites() async {
    isLoading = true;
    notifyListeners();
    final response = await http.get(Uri.parse('${Constant.baseUrl}/api/Product/favorites'));

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      this._favorites = jsonResponse.map((item) => Favorite.fromJson(item)).toList();
      isLoading = false;
      notifyListeners();
      return this._favorites;
    } else {
      throw Exception('Failed to load favorites: ${response.statusCode}');
    }
    notifyListeners();
  }

  Future<bool> IsFavorite(int productId) async{
    return favorites.any((favorite) => favorite.id == productId);
  }

  Future<bool> addFavorite(int productId) async {
    final response = await http.post(
      Uri.parse('${Constant.baseUrl}/api/Product/favorite/$productId'),
      headers: {'accept': '*/*'},
    );

    if (response.statusCode != 200) {
      return false;
    }
    else{
      await fetchFavorites();
      return true;
    }
  }

  Future<bool> deleteFavorite(int id) async {
    final response = await http.delete(
      Uri.parse('${Constant.baseUrl}/api/Product/favorite/$id'),
      headers: {'accept': '*/*'},
    );

    if (response.statusCode != 200) {
      return false;
    }
    else{
      await fetchFavorites();
      return true;
    }
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Screens/filter_screen.dart';
import '../Screens/product_detail_screen.dart';
import '../providers/constants.dart';
import '../providers/productlistresponse.dart';
import '../providers/productsapi.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<ProductListResponse>? futureProducts;
  final TextEditingController _searchController = TextEditingController(text: '');
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    futureProducts = fetchCategoryProducts();
  }

  Future<ProductListResponse> fetchCategoryProducts() async {
    final baseUrl = Constant.baseUrl;
    final response = await http.get(Uri.parse('$baseUrl/api/Product/home'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProductListResponse.fromJson(data);
    } else {
      throw Exception('Failed to load products');
    }
  }
  void _navigateToFilterScreen() {
    final searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FilterScreen(searchText: searchText),
        ),
      );
    }
  }
  Widget buildCategoryProductList(String title, List<ProductApi> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    // Navigator.of(context).pushNamed(
                    //   ProductDetailScreen.routeName,
                    //   arguments: product.id.toString(),
                    // );
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(productId: product.id)));
                  },
                  child: FurnitureCard(
                    product: {
                      'id': product.id,
                      'title': product.name,
                      'subtitle': product.name,
                      'price': '\$${product.amount}',
                      'imageUrl': product.photoUrl,
                      'isNew': false,
                      'rating': '4.5',
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Discover the Best Device Tech',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for devices...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.grey),
                      onPressed: _navigateToFilterScreen,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  onSubmitted: (value){
                    _navigateToFilterScreen;
                  },
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              FutureBuilder<ProductListResponse>(
                future: futureProducts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData ||
                      snapshot.data!.categoryProducts.isEmpty) {
                    return const Center(child: Text("No products available."));
                  }

                  final categories = snapshot.data!.categoryProducts;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categories
                        .take(5)
                        .map((categoryProduct) => buildCategoryProductList(
                              categoryProduct.category,
                              categoryProduct.products,
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FurnitureCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const FurnitureCard({required this.product, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.of(context).pushNamed(
        //   ProductDetailScreen.routeName,
        //   arguments: product['id'].toString(),
        // );
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                ProductDetailScreen(productId: product['id'])));
      },
      child: Container(
        width: 160,
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            )
          ],
        ),
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                product['imageUrl'],
                height: 120,
                width: double.infinity,
                //fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (product['isNew'])
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      Spacer(),
                      // Icon(Icons.star, color: Colors.yellow, size: 16),
                      // Text('${product['rating']}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['title'],
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    product['subtitle'],
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product['price'] ?? '',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

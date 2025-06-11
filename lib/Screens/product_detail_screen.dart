import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import '../models/product_data.dart';
import '../providers/cart.dart';
import '../providers/favorite_provider.dart';
import '../providers/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  static const routeName = '/product-detail';

  const ProductDetailScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductResponse? productResponse;
  ProductDetail? product;
  List<ProductVariant>? variants;
  bool addedToCart = false;
  bool isFavorite = false;
  FavoriteProvider? favoriteProvider;
  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final productService = ProductService();
    favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    isFavorite = (await favoriteProvider?.IsFavorite(widget.productId))!;
    try {
      productResponse = await productService.getProductDetail(widget.productId);
      setState(() {
        product = productResponse!.products[widget.productId.toString()];
        variants = productResponse!.variants;
        _setVariantSelections();
      });

      // final cartService = Provider.of<CartService>(context, listen: false);
      // cartService.cartStoreItems.listen((items) {
      //   setState(() {
      //     addedToCart = items.any((i) => i['productId'] == product!.id);
      //   });
      // });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading product: $e')),
      );
    }
  }

  void _setVariantSelections() {
    for (var variant in variants!) {
      variant.selected = product!.properties
          .firstWhere((p) => p.name == variant.name,
          orElse: () => ProductProperty(name: '', value: ''))
          .value;
    }
  }

  void _changeVariant(String name, String value) async {
    final productService = ProductService();
    final newId = productService.getTargetVariant(
      name,
      value,
      variants!,
      productResponse!.products,
    );

    if (newId != null && newId != widget.productId) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(productId: newId),
        ),
      );
    }
  }

  void _onCartClick() {
    final cartService = Provider.of<Cart>(context, listen: false);
    cartService.addToCart(context, product!.storeItemId, product!.id, Provider.of<Auth>(context, listen: false).token);
    // if (addedToCart) {
    //   cartService.removeFromCart(product!.id);
    // } else {
    //   cartService.addToCart(product!.storeItemId, product!.id);
    // }
    // setState(() {
    //   addedToCart = !addedToCart;
    // });
  }
  void _onCartFavorite() async {
    if(!isFavorite){
      var addFavorite = (await favoriteProvider?.addFavorite(product!.id));
      isFavorite = (await favoriteProvider?.IsFavorite(widget.productId))!;
      print(isFavorite);
      if (addFavorite == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item added to favorite successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to add item to favorite'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    else{
      var addFavorite = (await favoriteProvider?.deleteFavorite(product!.id));
      isFavorite = (await favoriteProvider?.IsFavorite(widget.productId))!;
      if (addFavorite == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item deleted from favorite successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to delete item from favorite'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        product = productResponse!.products[widget.productId.toString()];
        variants = productResponse!.variants;
        _setVariantSelections();
      });
    }
    setState(() {
      product = productResponse!.products[widget.productId.toString()];
      variants = productResponse!.variants;
      _setVariantSelections();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (product == null || variants == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product!.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
            height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: product!.photos.length,
                    controller: PageController(viewportFraction: 1),
                    itemBuilder: (context, index) {
                      return Image.network(
                        product!.photos[index].url,
                        //fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.error));
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product!.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    '\$${product!.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Mô tả
                  Text(
                    product!.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Features:\n${product!.features}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  // Variants
                  ...variants!.map((variant) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variant.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Wrap(
                          spacing: 8,
                          children: variant.values.map((value) {
                            return ChoiceChip(
                              label: Text(value),
                              selected: variant.selected == value,
                              onSelected: (selected) {
                                if (selected) {
                                  _changeVariant(variant.name, value);
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                  ElevatedButton(
                    onPressed: _onCartClick,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: Text(
                      addedToCart ? 'Remove from Cart' : 'Add to Cart', style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                    ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _onCartFavorite,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      isFavorite ? 'Remove from Favorite' : 'Add to Favorite', style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
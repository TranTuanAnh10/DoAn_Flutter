import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/product.dart';
import '../Screens/product_detail_screen.dart';
import '../providers/cart.dart';

//widget cho từng ô sản phẩm
class ProductItem extends StatelessWidget {
  const ProductItem({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          child: Hero(
            tag: 'overview-${product.id.toString()}',
            child: FadeInImage(
              placeholder:
                  const AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(
                product.imageUrl,
              ),
              fit: BoxFit.cover,
            ),
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    ProductDetailScreen(productId: product.id as int)));
          },
        ),
        footer: GridTileBar(
          // thanh bar dưới hình ảnh sản phẩm
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                product.toggleFavoriteStatus(authData.token, authData.userId);
              },
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          backgroundColor: Colors.black87,
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              //cart.addItem(product.id.toString(), product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text("Added item to the cart!"),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: "Undo",
                  onPressed: () => cart.removeSingleItem(product.id.toString()),
                ),
              ));
            },
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}

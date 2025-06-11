import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Screens/edit_products_screen.dart';
import '../widgets/app-drawer.dart';
import '../providers/products.dart';
import '../widgets/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/user-product-screen';
  const UserProductScreen({Key? key}) : super(key: key);
  Future<void> _refreshProduct(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetUserData();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("rebuilding...");
    // final productData = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: _refreshProduct(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProduct(context),
                    child: Consumer<Products>(
                      builder: (context, productData, _) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: productData.userItems.length,
                          itemBuilder: (_, index) => Column(
                            children: [
                              UserProductItem(
                                id: productData.userItems[index].id.toString(),
                                imageUrl: productData.userItems[index].imageUrl,
                                title: productData.userItems[index].title,
                                updateProd: _refreshProduct(context),
                              ),
                              const Divider(
                                color: Colors.grey,
                                thickness: 1,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}

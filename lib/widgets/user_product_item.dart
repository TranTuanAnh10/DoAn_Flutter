import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Screens/edit_products_screen.dart';
import '../providers/products.dart';

class UserProductItem extends StatelessWidget {
  const UserProductItem(
      {Key? key,
      required this.imageUrl,
      required this.title,
      required this.id,
      required this.updateProd})
      : super(key: key);
  final String id;
  final String title;
  final String imageUrl;
  final Future<void> updateProd;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          onPressed: () {
            Navigator.of(context)
                .pushNamed(EditProductScreen.routeName, arguments: id);
          },
          icon: const Icon(Icons.edit),
          color: Theme.of(context).colorScheme.secondary,
        ),
        IconButton(
          onPressed: () {
            try {
              Provider.of<Products>(context, listen: false).deleteProduct(id);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delete Sucessfull')));
            } catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Something went wrong with network')));
            }
          },
          icon: const Icon(Icons.delete),
          color: Theme.of(context).colorScheme.error,
        )
      ]),
    );
  }
}

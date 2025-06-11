import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Screens/product_detail_screen.dart';
import '../models/favorite.dart';
import '../providers/favorite_provider.dart';

class FavoriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavoriteProvider()..fetchFavorites(),
      child: Builder(
        builder: (BuildContext providerContext) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Favorite', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.blueAccent,
            ),
            body: RefreshIndicator(
              onRefresh: Provider.of<FavoriteProvider>(providerContext, listen: false).fetchFavorites,
              child: Consumer<FavoriteProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (provider.favorites.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'You don\'t have any favorite products yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: provider.favorites.length,
                    itemBuilder: (context, index) {
                      final favorite = provider.favorites[index];
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: favorite.photoUrl != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              favorite.photoUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200],
                                child: Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            ),
                          )
                              : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                          title: Text(
                            favorite.name,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Price: ${favorite.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                                // Text(
                                //   'Status: ${favorite.available ? 'In stock' : 'Out of stock'}',
                                //   style: TextStyle(
                                //     fontSize: 14,
                                //     color: favorite.available ? Colors.green : Colors.red,
                                //   ),
                                // ),
                                if (favorite.features != null)
                                  Text(
                                    'Features: ${favorite.features}',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  ),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_forever, color: Colors.redAccent),
                            onPressed: () {
                              provider.deleteFavorite(favorite.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Removed ${favorite.name} from favorites'),
                                    ],
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen(productId: favorite.id)));
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
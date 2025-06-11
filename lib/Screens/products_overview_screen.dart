import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import '../providers/cart.dart';
import '../widgets/app-drawer.dart';
import '../widgets/favorite_screen.dart';
import '../widgets/product_grid.dart';
import '../Screens/cart_screen.dart';
import '../widgets/profile-screen.dart';

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({Key? key}) : super(key: key);
  static const routeName = "/overview-screen";
  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var cartCount = 0;
  bool isDarkMode = false;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<Products>(context, listen: false).fetchAndSetAllData();
    }
    _isInit = false;
    super.didChangeDependencies();
    final cartService = Provider.of<Cart>(context, listen: false);
    cartCount = cartService.itemCount;
  }

  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          indicatorColor: Colors.amber,
          selectedIndex: currentPageIndex,
          destinations: <Widget>[
            NavigationDestination(
              selectedIcon: FaIcon(
                FontAwesomeIcons.house,
                color: Colors.white,
              ),
              icon: FaIcon(
                FontAwesomeIcons.house,
                color: Colors.black,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: FaIcon(
                FontAwesomeIcons.heart,
                color: Colors.white,
              ),
              icon: FaIcon(
                FontAwesomeIcons.solidHeart,
                color: Colors.black,
              ),
              label: 'Favorite',
            ),
            NavigationDestination(
              selectedIcon: FaIcon(
                FontAwesomeIcons.cartShopping,
                color: Colors.white,
              ),
              icon: FaIcon(
                FontAwesomeIcons.cartShopping,
                color: Colors.black,
              ),
              label: 'Cart',
            ),
            NavigationDestination(
              selectedIcon: FaIcon(FontAwesomeIcons.user, color: Colors.white),
              icon: FaIcon(FontAwesomeIcons.userLarge, color: Colors.black),
              label: 'Profile',
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: <Widget>[
          /// Home page
          HomeScreen(),
          FavoriteScreen(),
          CartScreen(),
          ProfileScreen(),
        ][currentPageIndex]);
  }
}

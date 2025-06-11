import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/providers/favorite_provider.dart';
import './providers/theme_provider.dart';
import './Screens/splash_screen.dart';
import '/Screens/edit_products_screen.dart';
import '../providers/orders.dart';
import './Screens/products_overview_screen.dart';
import './Screens/product_detail_screen.dart';
import './providers/products.dart';
import 'package:provider/provider.dart';
import './Screens/cart_screen.dart';
import 'providers/cart.dart';
import 'Screens/orders_screen.dart';
import 'Screens/user_products_screen.dart';
import 'Screens/auth_screen.dart';
import 'providers/auth.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final ThemeData _lightThemeData = ThemeData(
      fontFamily: 'Lato',
      brightness: Brightness.light,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        TargetPlatform.android: CustomPageTransitionBuilder(),
        TargetPlatform.iOS: CustomPageTransitionBuilder(),
      }),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
          .copyWith(surface: Colors.white));
  final ThemeData _darkThemeData = ThemeData(
      fontFamily: 'Lato',
      brightness: Brightness.dark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        TargetPlatform.android: CustomPageTransitionBuilder(),
        TargetPlatform.iOS: CustomPageTransitionBuilder(),
      }),
      colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.deepPurple, brightness: Brightness.dark)
          .copyWith(surface: Colors.black));
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
              create: (context) => Products('', '', [], []),
              update: (context, auth, previousProducts) => Products(
                  auth.token,
                  auth.userId,
                  previousProducts == null ? [] : previousProducts.allItems,
                  previousProducts == null
                      ? []
                      : previousProducts
                          .userItems)), //better way to provide data than .value
          ChangeNotifierProvider(
            create: (context) => Cart(),
          ),
          ChangeNotifierProvider(
            create: (context) => FavoriteProvider()..fetchFavorites(),
          ),
          // ChangeNotifierProxyProvider<Auth, Orders>(
          //   create: (context) => Orders('', '', []),
          //   update: (context, auth, previousProducts) => Orders(
          //       auth.token,
          //       auth.userId,
          //       previousProducts == null ? [] : previousProducts.orders),
          // ),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ],
        child: Consumer2<Auth, ThemeProvider>(
          builder: ((context, auth, themeMode, _) => MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Flutter Demo',
                themeMode: themeMode.mode,
                theme: _lightThemeData.copyWith(
                    colorScheme: _lightThemeData.colorScheme
                        .copyWith(secondary: Colors.orange)),
                darkTheme: _darkThemeData.copyWith(
                    colorScheme: _darkThemeData.colorScheme
                        .copyWith(secondary: Colors.deepOrange)),
                home: auth.isAuth
                    ? const ProductOverviewScreen()
                    : FutureBuilder(
                        future: auth.tryAutoLogin(),
                        builder: ((context, authSnapshot) =>
                            authSnapshot.connectionState ==
                                    ConnectionState.waiting
                                ? const SplashScreen()
                                : const AuthScreen())),
                routes: {
                  // ProductDetailScreen.routeName: (context) =>
                  //     const ProductDetailScreen(productId: 1),
                  CartScreen.routeName: (context) => const CartScreen(),
                  //OrdersScreen.routeName: (context) => const OrdersScreen(),
                  UserProductScreen.routeName: (context) =>
                      const UserProductScreen(),
                  EditProductScreen.routeName: (context) =>
                      const EditProductScreen(),
                  AuthScreen.routeName: (context) => const AuthScreen(),
                  ProductOverviewScreen.routeName: (context) =>
                      const ProductOverviewScreen(),
                },
              )),
        ));
  }
}

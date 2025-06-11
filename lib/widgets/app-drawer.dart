// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/custom_route.dart';
import 'package:shop_app/providers/theme_provider.dart';
import '../Screens/user_products_screen.dart';
import '../Screens/orders_screen.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // bool isOn = _isDarkMode ? true : false;
    return Drawer(
      child: Column(children: [
        AppBar(
          title: const Text(
            "Shop",
          ),
          automaticallyImplyLeading: false,
        ),
        ListTile(
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
          title: const Text("Shop"),
          leading: const Icon(Icons.shop),
        ),
        const Divider(),
        ListTile(
          onTap: () {
            // Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
            // Navigator.of(context).pushReplacement(
            //     CustomRoute(builder: (ctx) => const OrdersScreen()));
          },
          title: const Text("Order"),
          leading: const Icon(Icons.credit_card),
        ),
        const Divider(),
        ListTile(
          onTap: () {
            Navigator.of(context)
                .pushReplacementNamed(UserProductScreen.routeName);
          },
          title: const Text("Manage Products"),
          leading: const Icon(Icons.edit),
        ),
        const Divider(),
        ListTile(
          title: const Text('Logout'),
          leading: const Icon(Icons.exit_to_app),
          onTap: () {
            Navigator.of(context).pop();
            Provider.of<Auth>(context, listen: false).logout();
          },
        ),
        const Divider(),
        ListTile(
          title:
              _isDarkMode ? const Text("Light Mode") : const Text("Dark Mode"),
          leading: const Icon(Icons.brightness_1),
          // subtitle: Switch(
          //     value: isDarkMode,
          //     onChanged: (value) {
          //       isDarkMode = value;
          //     }),
          onTap: () {
            Provider.of<ThemeProvider>(context, listen: false).changeMode();
          },
        )
      ]),
    );
  }
}

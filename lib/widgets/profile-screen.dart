import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/Screens/auth_screen.dart';
import 'package:shop_app/models/userdata.dart';
import '../Screens/OrderHistoryScreen.dart';
import '../Screens/PrivacyPolicyScreen.dart';
import '../Screens/SettingsScreen.dart';
import '../Screens/TermsConditionsScreen.dart';
import '../providers/auth.dart'; // giả sử bạn có class Auth chứa token
import 'product_item.dart'; // nơi chứa hàm fetchUserProfile

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserData? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    try {
      final user =
          await Provider.of<Auth>(context, listen: false).getUserData();
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: ' + e.toString());
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      if (_user == null) {
        return const Scaffold(
          body: Center(child: Text("Failed to load profile.")),
        );
      } else {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.white,
          ),
          body: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "My Profile",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                              "https://randomuser.me/api/portraits/men/41.jpg"),
                        ),
                        // Positioned(
                        //   bottom: 0,
                        //   right: 0,
                        //   child: CircleAvatar(
                        //     radius: 15,
                        //     backgroundColor: Colors.white,
                        //     child: Icon(Icons.camera_alt, size: 18),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _user!.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _user!.email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  children: [
                    ProfileMenuItem(
                      icon: Icons.settings,
                      text: "Settings",
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(user: _user!),
                          ),
                        );

                        if (updated == true) {
                          print("Get new data");
                          await _loadProfile();
                        }
                      },
                    ),

                    // ProfileMenuItem(
                    //     icon: Icons.notifications, text: "Notifications"),
                    ProfileMenuItem(
                      icon: Icons.history,
                      text: "Order History",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => OrderHistoryScreen()),
                        );
                      },
                    ),
                    const Divider(),
                    ProfileMenuItem(
                      icon: Icons.privacy_tip,
                      text: "Privacy & Policy",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen()),
                      ),
                    ),
                    ProfileMenuItem(
                      icon: Icons.article,
                      text: "Terms & Conditions",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TermsConditionsScreen()),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Logout'),
                      leading: const Icon(Icons.exit_to_app),
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }
  }
}

void _logoutUser(BuildContext context) {
  // Here you can add your logout logic, like clearing session or navigating to login screen.
  Navigator.of(context)
      .pushReplacementNamed('/login'); // Example: Navigate to login screen
}

// Function to show logout confirmation dialog
void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Log Out"),
      content: const Text("Are you sure you want to log out?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(), // Đóng dialog
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop(); // Đóng dialog trước
            await Future.delayed(Duration(microseconds: 300), () {
              Provider.of<Auth>(context, listen: false).logout();
            });
            Navigator.of(context).pushReplacement(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  AuthScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0); // Từ bên phải
                const end = Offset.zero;
                const curve = Curves.bounceOut;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(position: offsetAnimation, child: child);
              },
            ));
          },
          child: const Text("Log Out", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Colors.black,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

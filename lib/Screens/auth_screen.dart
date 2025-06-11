import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Screens/products_overview_screen.dart';
import '../providers/auth.dart';
import '../models/http_exception.dart';
import '../providers/cart.dart';

enum AuthMode { signup, login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: deviceSize.height,
        width: deviceSize.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: BackgroundPainter(),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20),
                child: SizedBox(
                  width: deviceSize.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 20, top: 40),
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            "assets/images/LogoShopElectro.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const AuthCard(),
                      const SizedBox(height: 20), // Extra padding to prevent bottom clipping
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
        size.width * 0.25, size.height * 0.4, size.width * 0.5, size.height * 0.3);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.2, size.width, size.height * 0.4);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'name': '',
    'dateOfBirth': '',
    'gender': '',
    'phoneNumber': '',
    'email': '',
    'username': '',
    'password': '',
  };
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  var _isLoading = false;
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('An Error Occurred'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.login) {
        await Provider.of<Auth>(context, listen: false).signIn(
          _authData['username'].toString(),
          _authData['password'].toString(),
        );
        final token = Provider.of<Auth>(context, listen: false).token;
        await Provider.of<Cart>(context, listen: false).fetchCartFromApi(token);
        Navigator.of(context).pushNamed(ProductOverviewScreen.routeName);
      } else {
        await Provider.of<Auth>(context, listen: false).signUp(
          _authData['name'].toString(),
          _authData['dateOfBirth'].toString(),
          _authData['gender'].toString(),
          _authData['phoneNumber'].toString(),
          _authData['email'].toString(),
          _authData['username'].toString(),
          _authData['password'].toString(),
        );
        _authMode = AuthMode.login;
        _controller.reverse();
      }
    } on HttpException {
      _showErrorDialog('Authentication failed');
    } catch (error) {
      _showErrorDialog(error.toString());
      debugPrint(error.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signup;
        _controller.forward();
      });
    } else {
      setState(() {
        _authMode = AuthMode.login;
        _controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: Container(
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.signup ? 460 : 280,
          maxWidth: deviceSize.width * 0.85,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _authMode == AuthMode.login ? 'Login' : 'Sign Up',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 20),
                _textFieldForAuthScreen(
                  "Username",
                  _userNameController,
                  onSave: (value) {
                    _authData['username'] = value ?? '';
                  },
                  onValidate: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _textFieldForAuthScreen(
                  "Password",
                  _passwordController,
                  isPassword: true,
                  onValidate: (value) {
                    if (value == null || value.length < 5) {
                      return 'Password must be at least 5 characters';
                    }
                    return null;
                  },
                  onSave: (value) {
                    _authData['password'] = value ?? '';
                  },
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: _authMode == AuthMode.signup ? null : 0,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_authMode == AuthMode.signup) ...[
                          const SizedBox(height: 16),
                          _textFieldForAuthScreen(
                            "Confirm Password",
                            _confirmPasswordController,
                            isPassword: true,
                            onValidate: (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _textFieldForAuthScreen(
                            "Name",
                            _nameController,
                            onValidate: (value) {
                              if (value == null || value.isEmpty){
                                return 'Please enter your name';
                              }
                              else{
                                _authData['name'] = value ?? '';
                              }
                            },
                            onSave: (value) {
                                _authData['name'] = value ?? '';
                            },
                          ),
                          const SizedBox(height: 16),
                          _textFieldForAuthScreen(
                            "Email",
                            _emailController,
                            inputType: TextInputType.emailAddress,
                            onValidate: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Invalid email address';
                              }
                              return null;
                            },
                            onSave: (value) {
                              _authData['email'] = value ?? '';
                            },
                          ),
                          const SizedBox(height: 16),
                          _textFieldForAuthScreen(
                            "Phone Number",
                            _phoneController,
                            inputType: TextInputType.phone,
                            onValidate: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                            onSave: (value) {
                              _authData['phoneNumber'] = value ?? '';
                            },
                          ),
                          const SizedBox(height: 16),
                          _genderDropdownForAuthScreen(
                            onSave: (value) {
                              _authData['gender'] = value ?? 'Unknown';
                            },
                          ),
                          const SizedBox(height: 16),
                          _textFieldForAuthScreen(
                            "Date of Birth",
                            _dobController,
                            onTap: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: DateTime(2000),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                _dobController.text = date.toIso8601String();
                                _authData['dateOfBirth'] = date.toIso8601String();
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  GestureDetector(
                    onTapDown: (_) {
                      setState(() {
                        _scale = 0.95;
                      });
                    },
                    onTapUp: (_) {
                      setState(() {
                        _scale = 1.0;
                      });
                    },
                    onTapCancel: () {
                      setState(() {
                        _scale = 1.0;
                      });
                    },
                    child: AnimatedScale(
                      scale: _scale,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade600, Colors.blue.shade900],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: Text(
                            _authMode == AuthMode.login ? 'Login' : 'Sign Up',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _switchAuthMode,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue.shade600,
                    ),
                    child: Text(
                      _authMode == AuthMode.login
                          ? 'Don\'t have an account? Sign Up'
                          : 'Already have an account? Login',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _scale = 1.0;

  Widget _textFieldForAuthScreen(
      String label,
      TextEditingController controller, {
        bool isPassword = false,
        TextInputType inputType = TextInputType.text,
        String? Function(String?)? onValidate,
        void Function(String?)? onSave,
        VoidCallback? onTap,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        prefixIcon: Icon(
          isPassword ? Icons.lock : Icons.person,
          color: Colors.blue.shade600,
        ),
      ),
      validator: onValidate,
      onSaved: onSave,
      onTap: onTap,
    );
  }

  String _gender = 'Unknown';
  Widget _genderDropdownForAuthScreen({void Function(String?)? onSave}) {
    return DropdownButtonFormField<String>(
      value: _gender,
      items: ['Male', 'Female', 'Unknown'].map((gender) {
        return DropdownMenuItem(value: gender, child: Text(gender));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _gender = value!;
        });
      },
      onSaved: onSave,
      decoration: InputDecoration(
        labelText: "Gender",
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        prefixIcon: Icon(Icons.transgender, color: Colors.blue.shade600),
      ),
    );
  }
}
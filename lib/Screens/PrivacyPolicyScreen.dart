import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy & Policy")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          "This is the Privacy Policy.\n\nYour information is safe with us. We do not share your personal data with third parties.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

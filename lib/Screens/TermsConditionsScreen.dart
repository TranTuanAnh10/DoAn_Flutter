import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms & Conditions")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          "These are the Terms & Conditions.\n\nBy using this app, you agree to our rules and conditions.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

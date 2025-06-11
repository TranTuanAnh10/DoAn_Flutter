

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/userdata.dart';
import '../providers/auth.dart';
import '../providers/constants.dart';

class SettingsScreen extends StatefulWidget {
  final UserData user;

  const SettingsScreen({Key? key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  String _gender = 'Unknown';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _dobController = TextEditingController(
      text: widget.user.dateOfBirth != null
          ? DateFormat('yyyy-MM-dd').format(widget.user.dateOfBirth!)
          : '',
    );
    _gender = widget.user.gender ?? 'Unknown';
  }

  void _submitForm() async {
    if (_nameController.text == widget.user.name &&
        _emailController.text == widget.user.email &&
        _phoneController.text == widget.user.phoneNumber &&
        _dobController.text == DateFormat('yyyy-MM-dd').format(widget.user.dateOfBirth) &&
        _gender == widget.user.gender) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No changes detected.")),
      );
      return;
    }

    final url = Uri.parse("${Constant.baseUrl}/api/Account/profile");
    try {
      final response = await http.post(
        url,
        headers: {
          'accept': 'text/plain',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Provider.of<Auth>(context, listen: false).token}',
        },
        body: json.encode({
          'id': widget.user.id,
          'name': _nameController.text,
          'dateOfBirth': _dobController.text,
          'gender': _gender,
          'phoneNumber': _phoneController.text,
          'email': _emailController.text,
          'userName': widget.user.userName,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully.")),
        );
        Navigator.pop(context, true); // Trả về giá trị true
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Full Name", _nameController),
              const SizedBox(height: 15),
              _buildTextField("Email", _emailController),
              const SizedBox(height: 15),
              _buildTextField("Phone Number", _phoneController),
              const SizedBox(height: 15),
              _buildDatePicker(context),
              const SizedBox(height: 15),
              _buildGenderDropdown(),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _submitForm,
                icon: const Icon(Icons.save, color: Colors.white,),
                label: const Text("Save Changes", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return TextFormField(
      controller: _dobController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Date of Birth",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: const Icon(Icons.calendar_today),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: widget.user.dateOfBirth ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
    );
  }

  Widget _buildGenderDropdown() {
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
      decoration: InputDecoration(
        labelText: "Gender",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}

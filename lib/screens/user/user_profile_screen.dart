// File: lib/screens/user/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_performance_mapping/models/user_model.dart';
import 'package:staff_performance_mapping/providers/auth_provider.dart';
import 'package:staff_performance_mapping/widgets/custom_text_field.dart';
import 'package:staff_performance_mapping/widgets/custom_button.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserModel _user;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: FutureBuilder<UserModel?>(
        future: authProvider.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          _user = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    initialValue: _user.firstName,
                    labelText: 'First Name',
                    onSaved: (value) =>
                        _user = _user.copyWith(firstName: value),
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    initialValue: _user.middleName,
                    labelText: 'Middle Name',
                    onSaved: (value) =>
                        _user = _user.copyWith(middleName: value),
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    initialValue: _user.surname,
                    labelText: 'Surname',
                    onSaved: (value) => _user = _user.copyWith(surname: value),
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    initialValue: _user.phoneNumber,
                    labelText: 'Phone Number',
                    onSaved: (value) =>
                        _user = _user.copyWith(phoneNumber: value),
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: CustomButton(
                      text: 'Update Profile',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          // TODO: Implement profile update logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Profile updated successfully')),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

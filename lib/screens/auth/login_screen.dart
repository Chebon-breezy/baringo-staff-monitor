import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_performance_mapping/providers/auth_provider.dart';
import 'package:staff_performance_mapping/screens/auth/register_screen.dart';
import 'package:staff_performance_mapping/screens/auth/department_selection_screen.dart';
import 'package:staff_performance_mapping/screens/user/user_home_screen.dart';
import 'package:staff_performance_mapping/screens/admin/admin_dashboard.dart';
import 'package:staff_performance_mapping/widgets/custom_text_field.dart';
import 'package:staff_performance_mapping/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                labelText: 'Email',
                validator: (value) => value!.isEmpty ? 'Enter an email' : null,
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Password',
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? 'Enter a password 6+ chars long' : null,
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Sign In',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    bool result = await authProvider.signIn(_email, _password);
                    if (result) {
                      final user = await authProvider.getCurrentUser();
                      if (user != null) {
                        if (user.department.isEmpty) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DepartmentSelectionScreen(user: user)),
                          );
                        } else {
                          bool isAdmin = await authProvider.isAdmin();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => isAdmin
                                  ? const AdminDashboard()
                                  : const UserHomeScreen(),
                            ),
                          );
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to sign in')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                child: const Text('Need an account? Register'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

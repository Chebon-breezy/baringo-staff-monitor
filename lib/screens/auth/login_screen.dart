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

  void _showForgotPasswordDialog(
      BuildContext context, AuthProvider authProvider) {
    String resetEmail = '';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter your email address to reset your password.'),
                const SizedBox(height: 16),
                CustomTextField(
                  labelText: 'Email',
                  onSaved: (value) => resetEmail = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter an email' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Reset Password'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  try {
                    await authProvider.resetPassword(resetEmail);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Password reset email sent. Check your inbox.')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to send reset email: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      _showForgotPasswordDialog(context, authProvider),
                  child: const Text('Forgot Password?'),
                ),
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

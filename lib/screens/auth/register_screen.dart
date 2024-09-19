import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_performance_mapping/models/user_model.dart';
import 'package:staff_performance_mapping/providers/auth_provider.dart';
import 'package:staff_performance_mapping/widgets/custom_text_field.dart';
import 'package:staff_performance_mapping/widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserModel _user = UserModel(
    id: '',
    firstName: '',
    middleName: '',
    surname: '',
    idNumber: '',
    phoneNumber: '',
    email: '',
    department: '',
    county: '',
    subCounty: '',
    ward: '',
    workstation: '',
  );
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            CustomTextField(
              labelText: 'First Name',
              validator: (value) =>
                  value!.isEmpty ? 'Enter your first name' : null,
              onSaved: (value) => _user = _user.copyWith(firstName: value),
            ),
            CustomTextField(
              labelText: 'Middle Name',
              onSaved: (value) => _user = _user.copyWith(middleName: value),
            ),
            CustomTextField(
              labelText: 'Surname',
              validator: (value) =>
                  value!.isEmpty ? 'Enter your surname' : null,
              onSaved: (value) => _user = _user.copyWith(surname: value),
            ),
            CustomTextField(
              labelText: 'ID Number',
              validator: (value) =>
                  value!.isEmpty ? 'Enter your ID number' : null,
              onSaved: (value) => _user = _user.copyWith(idNumber: value),
            ),
            CustomTextField(
              labelText: 'Phone Number',
              validator: (value) =>
                  value!.isEmpty ? 'Enter your phone number' : null,
              onSaved: (value) => _user = _user.copyWith(phoneNumber: value),
            ),
            CustomTextField(
              labelText: 'Email',
              validator: (value) => value!.isEmpty ? 'Enter an email' : null,
              onSaved: (value) => _user = _user.copyWith(email: value),
            ),
            CustomTextField(
              labelText: 'Department',
              validator: (value) =>
                  value!.isEmpty ? 'Enter your department' : null,
              onSaved: (value) => _user = _user.copyWith(department: value),
            ),
            CustomTextField(
              labelText: 'County',
              validator: (value) => value!.isEmpty ? 'Enter your county' : null,
              onSaved: (value) => _user = _user.copyWith(county: value),
            ),
            CustomTextField(
              labelText: 'Sub County',
              validator: (value) =>
                  value!.isEmpty ? 'Enter your sub county' : null,
              onSaved: (value) => _user = _user.copyWith(subCounty: value),
            ),
            CustomTextField(
              labelText: 'Ward',
              validator: (value) => value!.isEmpty ? 'Enter your ward' : null,
              onSaved: (value) => _user = _user.copyWith(ward: value),
            ),
            CustomTextField(
              labelText: 'Workstation',
              validator: (value) =>
                  value!.isEmpty ? 'Enter your workstation' : null,
              onSaved: (value) => _user = _user.copyWith(workstation: value),
            ),
            CustomTextField(
              labelText: 'Password',
              obscureText: true,
              validator: (value) =>
                  value!.length < 6 ? 'Enter a password 6+ chars long' : null,
              onSaved: (value) => _password = value!,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Register',
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  bool result = await authProvider.signUp(_user, _password);
                  if (result) {
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to register')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:staff_performance_mapping/models/user_model.dart';
import 'package:staff_performance_mapping/providers/auth_provider.dart';

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

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Register'),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildCupertinoTextField(
                placeholder: 'First Name',
                onChanged: (value) => _user = _user.copyWith(firstName: value),
              ),
              _buildCupertinoTextField(
                placeholder: 'Middle Name',
                onChanged: (value) => _user = _user.copyWith(middleName: value),
              ),
              _buildCupertinoTextField(
                placeholder: 'Surname',
                onChanged: (value) => _user = _user.copyWith(surname: value),
              ),
              _buildCupertinoTextField(
                placeholder: 'ID Number',
                onChanged: (value) => _user = _user.copyWith(idNumber: value),
              ),
              _buildCupertinoTextField(
                placeholder: 'Phone Number',
                keyboardType: TextInputType.phone,
                onChanged: (value) =>
                    _user = _user.copyWith(phoneNumber: value),
              ),
              _buildCupertinoTextField(
                placeholder: 'Email',
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => _user = _user.copyWith(email: value),
              ),
              _buildCupertinoTextField(
                placeholder: 'Department',
                onChanged: (value) => _user = _user.copyWith(department: value),
              ),
              _buildCupertinoTextField(
                placeholder: 'County',
                onChanged: (value) => _user = _user.copyWith(county: value),
              ),
              _buildCupertinoTextField(
                placeholder: 'Sub County',
                onChanged: (value) => _user = _user.copyWith(subCounty: value),
              ),
              _buildCupertinoTextField(
                placeholder: 'Ward',
                onChanged: (value) => _user = _user.copyWith(ward: value),
              ),
              _buildCupertinoTextField(
                placeholder: 'Workstation',
                onChanged: (value) =>
                    _user = _user.copyWith(workstation: value),
              ),
              _buildCupertinoTextField(
                placeholder: 'Password',
                obscureText: true,
                onChanged: (value) => _password = value,
              ),
              const SizedBox(height: 24),
              CupertinoButton.filled(
                child: const Text('Register'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    bool result = await authProvider.signUp(_user, _password);
                    if (result) {
                      Navigator.pop(context);
                    } else {
                      _showErrorDialog(context, 'Failed to register');
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoTextField({
    required String placeholder,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required void Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CupertinoTextField(
        placeholder: placeholder,
        obscureText: obscureText,
        keyboardType: keyboardType,
        clearButtonMode: OverlayVisibilityMode.editing,
        autocorrect: false,
        onChanged: onChanged,
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

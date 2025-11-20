import 'package:flutter/material.dart';
import 'package:monitoring_maintenance/controller/login_controller.dart';
import 'package:monitoring_maintenance/model/login_model.dart';
import 'package:monitoring_maintenance/screen/admin/dashboard_admin.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _loginController = LoginController();
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailOrPhoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email/Telepon dan Password harus diisi')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final credentials = LoginCredentials(
      emailOrPhone: _emailOrPhoneController.text,
      password: _passwordController.text,
    );

    final success = await _loginController.login(credentials);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Navigate to admin dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AdminTemplate()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal. Periksa kembali email/telepon dan password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A9C5D), Color(0xFF022415)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Aplikasi Monitoring\nMaintenance Mesin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 70),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Center(
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                              color: Color(0xFF078C51),
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _LoginTextField(
                          controller: _emailOrPhoneController,
                          hintText: 'E-mail atau nomor telepon',
                          textInputType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 18),
                        _LoginTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: true,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A9C5D),
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.controller,
    required this.hintText,
    this.textInputType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? textInputType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: textInputType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF0A9C5D),
            width: 1.4,
          ),
        ),
      ),
      style: const TextStyle(
        color: Color(0xFF022415),
        fontSize: 14,
      ),
    );
  }
}

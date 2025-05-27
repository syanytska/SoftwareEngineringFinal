import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/authService.dart';
import '../homePage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _role = 'User';
  bool _isLoading = false;
  bool _navigated = false;

  void _register() async {
    setState(() {
      _isLoading = true;
      _navigated = false;
    });

    final success = await AuthService().register(
      _usernameController.text,
      _passwordController.text,
      _role,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('role', _role);

      Future.delayed(Duration.zero, () {
        _navigated = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(username: _usernameController.text),
          ),
        );
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!_navigated && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration succeeded, but navigation failed."),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User already exists. Please login.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/transparent-happy-young-hispanic-school-boy-with-thumbs-up-png.webp',
                fit: BoxFit.cover,
                height: 300,
                width: 350,
              ),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Create Account',
                    textStyle: const TextStyle(
                      color: Colors.red,
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Times New Roman',
                      fontWeight: FontWeight.w500,
                    ),
                    speed: const Duration(milliseconds: 450),
                  ),
                ],
                isRepeatingAnimation: true,
                totalRepeatCount: 2,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: 'Enter Your Username',
                        labelText: 'Username',
                        hintStyle: TextStyle(color: Colors.grey),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        icon: Icon(Icons.lock),
                        hintText: 'Enter Your Password',
                        labelText: 'Password',
                        hintStyle: TextStyle(color: Colors.grey),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _role,
                      decoration: InputDecoration(
                        labelText: 'Role',
                        prefixIcon: const Icon(Icons.people, color: Colors.red),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: ['User', 'Admin', 'Guest'].map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _role = value);
                      },
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: _isLoading ? null : _register,
                      icon: const Icon(Icons.create),
                      label: Container(
                        alignment: Alignment.center,
                        width: 150,
                        height: 35,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'By signing up you agree to our terms, conditions and privacy policy.',
                      style: TextStyle(fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

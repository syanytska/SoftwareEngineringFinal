import 'package:flutter/material.dart';
import '../homePage.dart';
import 'registerPage.dart';
import '../../services/authService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _navigated = false;

  void _login() async {
    setState(() {
      _isLoading = true;
      _navigated = false;
    });

    final success = await AuthService().login(
      _usernameController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // try navigating
      Future.delayed(Duration.zero, () {
        _navigated = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(username: _usernameController.text),
          ),
        );
      });

      // wait and verify
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!_navigated && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login succeeded, but navigation failed."),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect username or password.'),
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
        child: Column(
          children: [
            Image.asset(
              'assets/transparent-happy-young-hispanic-school-boy-with-thumbs-up-png.webp',
              fit: BoxFit.cover,
              height: 300,
              width: 350,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'Courier',
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
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
                  TextButton.icon(
                    onPressed: _isLoading ? null : _login,
                    icon: const Icon(Icons.login),
                    label: Container(
                      alignment: Alignment.center,
                      width: 150,
                      height: 35,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Register here",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'By signing in you agree to our terms, conditions and privacy policy.',
                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

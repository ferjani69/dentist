import 'package:search/main.dart' show SearchPage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  bool _isLoading=false;
  Future<void> login() async {
    if (_formKey.currentState!.validate()) { // Only proceed if the form is valid
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      setState(() => _isLoading=true

      );
      try {
        setState(() =>_isLoading=false

        );
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        String? token = await userCredential.user?.getIdToken();
        if (token != null) {
          await storage.write(key: 'firebase_token', value: token);
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login successful')));
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SearchPage(patientadd: null)),)    ;  }
      catch (e) {
        setState(() =>_isLoading=false

        );
        String errorMessage = 'Login failed';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              errorMessage = 'No user found for that email.';
              break;
            case 'wrong-password':
              errorMessage = 'Wrong password provided for that user.';
              break;
            case 'network-request-failed':
              errorMessage = 'Check your internet connection and try again.';
              break;
          // Add more cases as necessary
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value!.isEmpty) return 'Email cannot be empty';
    String p = r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$";
    RegExp regExp = RegExp(p);
    if (!regExp.hasMatch(value)) return 'Please enter a valid email';
    return null; // return null if the entered email is valid
  }


  String? _validatePassword(String? value) {
    if (value!.isEmpty) return 'Password cannot be empty';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null; // return null if the entered password is valid
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
      children: [
      Positioned(
      top: 0,
        left: 0,
        right: 0,
        child: Opacity(
          opacity: 0.7,
          child: SvgPicture.asset(
            "assets/wavestop.svg",
            width: 250,
            height: 100,
          ),
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Opacity(
          opacity: 0.3,
          child: SvgPicture.asset(
            "assets/waves.svg",
            width: 250,
            height: 100,
          ),
        ),
      ),Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: _validatePassword,
                  obscureText: true,
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed:_isLoading ?null : login,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login'),                ),
                TextButton(
                  onPressed: () {
                    // Implement forgot password logic
                  },
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

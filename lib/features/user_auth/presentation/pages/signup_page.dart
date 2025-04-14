

import 'package:career_ally/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:career_ally/features/user_auth/presentation/pages/login_page.dart';
import 'package:career_ally/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

import '../../firebase_auth_implementation/verify_email_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigningUp = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _selectedRole = 'student'; // Default role

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Lottie.asset(
                'assets/login_animation.json', // Replace with your signup animation
                height: 150,
                width: 150,
                repeat: true,
              ),
              SizedBox(height: 20),
              Text(
                "Create Account",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Sign up to get started!",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),

              // *** INSERT THIS CODE HERE ***
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Radio(
                        value: 'student',
                        groupValue: _selectedRole,
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                      Text("Student"),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 'tpo',
                        groupValue: _selectedRole,
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                      Text("TPO"),
                    ],
                  ),
                ],
              ),
              // *** END OF INSERTION ***

              SizedBox(height: 20),  // Adjusted spacing

              FormContainerWidget(
                controller: _usernameController,
                hintText: "Username",
                isPasswordField: false,
                prefixIcon: Icons.person,
              ),
              SizedBox(
                height: 20,
              ),
              FormContainerWidget(
                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
                prefixIcon: Icons.email,
              ),
              SizedBox(
                height: 20,
              ),
              FormContainerWidget(
                controller: _passwordController,
                hintText: "Password",
                isPasswordField: true,
                prefixIcon: Icons.lock,
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: _isSigningUp ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSigningUp
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitThreeBounce(color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text("Creating...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                )
                    : Text(
                  "Sign Up",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?", style: TextStyle(color: Colors.grey[700])),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                            (route) => false,
                      );
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    setState(() {
      _isSigningUp = true;
    });
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter all fields.")),
      );
      setState(() {
        _isSigningUp = false;
      });
      return;
    }

    try {
      // ***  PASS THE SELECTED ROLE HERE ***
      User? user = await _auth.signUpWithEmailAndPassword(email, password, _selectedRole,username); // Pass the role
      setState(() {
        _isSigningUp = false;
      });

      if (user != null) {
        // Send verification email
        try {
          await user.sendEmailVerification();
          print("Verification email sent.");

          // Navigate to the Verify Email page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VerifyEmailPage()),
          );

        } catch (e) {
          print("Error sending verification email: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error sending verification email: ${e.toString()}")),
          );
        }
      } else {
        print("error occurred");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create user."),),
        );
      }
    } catch (e) {
      print("Error signing up: $e");
      setState(() {
        _isSigningUp = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing up: ${e.toString()}")),
      );
    }
  }
}
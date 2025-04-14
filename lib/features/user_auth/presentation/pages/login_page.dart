// import 'package:career_ally/features/user_auth/presentation/pages/signup_page.dart';
// import 'package:career_ally/features/user_auth/presentation/widgets/form_container_widget.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// import '../../firebase_auth_implementation/firebase_auth_services.dart';
//
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final FirebaseAuthService _auth = FirebaseAuthService();
//
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:AppBar(
//         title:Text("Login"),
//       ) ,
//       body:Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 15),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text("Login", style:TextStyle(fontSize:27,fontWeight: FontWeight.bold)),
//               SizedBox(
//                 height: 30,
//               ),
//           FormContainerWidget(
//             controller: _emailController,
//             hintText: "Email",
//             isPasswordField: false,
//           ),
//               SizedBox(height: 10,),
//               FormContainerWidget(
//                 controller: _passwordController,
//                 hintText: "Password",
//                 isPasswordField: true,
//               ),
//               SizedBox(height: 30,),
//
//               GestureDetector(
//                 onTap:_signIn,
//                 child: Container(
//                   width: double.infinity,
//                   height: 45,
//                   decoration: BoxDecoration(
//                     color: Colors.blue,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Center(child: Text("Login",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
//                 )
//                 ),
//               ),
//               SizedBox(height: 10,),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text("Don't have an account?"),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(builder: (context) => SignupPage()),
//                             (route) => false,
//                       );
//                     },
//                     child: Text(
//                       "Sign Up",
//                       style: TextStyle(
//                         color: Colors.blue,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _signIn() async {
//     String email=_emailController.text;
//     String password=_passwordController.text;
//
//     User? user =await _auth.signInWithEmailAndPassword(email, password);
//
//     if(user!=null){
//       print("user Sign in");
//       Navigator.pushNamed(context,"/home" );
//     }else{
//       print("error occurred");
//     }
//   }
// }



import 'package:career_ally/features/user_auth/presentation/pages/signup_page.dart';
import 'package:career_ally/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../firebase_auth_implementation/firebase_auth_services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import for loading indicator
import 'package:lottie/lottie.dart'; // Import for Lottie animations

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigningIn = false; // Track signing in state

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // A subtle background
      body: Center(
        child: SingleChildScrollView( // Make scrollable for smaller screens
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30), // Increased padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children to fill width
            children: [

              // Animated Logo (Lottie Example)
              Lottie.asset(
                'assets/login_animation.json', // Replace with your animation file
                height: 150, // Adjust as needed
                width: 150,
                repeat: true, // Set to false if you want it to play once
              ),
              SizedBox(height: 20),

              Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Login to continue",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),

              // Email Field
              FormContainerWidget(
                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
                prefixIcon: Icons.email, // Add email icon
              ),
              SizedBox(height: 20),

              // Password Field
              FormContainerWidget(
                controller: _passwordController,
                hintText: "Password",
                isPasswordField: true,
                prefixIcon: Icons.lock, // Add lock icon
              ),
              SizedBox(height: 30),

              // Login Button
              ElevatedButton(
                onPressed: _isSigningIn ? null : _signIn, // Disable button while signing in
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSigningIn
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitThreeBounce(color: Colors.white, size: 20), // Loading indicator
                    SizedBox(width: 10),
                    Text("Signing In...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                )
                    : Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),

              SizedBox(height: 20),

              // Don't have an account?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?", style: TextStyle(color: Colors.grey[700])),
                  SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                            (route) => false,
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Optional: Add "Forgot Password" Link
              TextButton(
                onPressed: () {
                  // TODO: Implement forgot password functionality
                  print("Forgot Password Pressed");
                },
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signIn() async {
    setState(() {
      _isSigningIn = true; // Start loading
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim(); //trim remove spaces

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter email and password.")),
      );
      setState(() {
        _isSigningIn = false;
      });
      return;
    }

    try {
      User? user = await _auth.signInWithEmailAndPassword(email, password);
      setState(() {
        _isSigningIn = false; // Stop loading
      });

      if (user != null) {
        print("User signed in");
        Navigator.pushNamed(context, "/home");
      } else {
        print("Sign-in failed");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid email or password.")),
        );
      }
    } catch (e) {
      print("Error signing in: $e");
      setState(() {
        _isSigningIn = false; // Stop loading in case of error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing in: ${e.toString()}")),
      );
    }
  }
}
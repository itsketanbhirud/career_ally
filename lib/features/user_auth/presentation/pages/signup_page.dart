//
//
// import 'package:career_ally/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
// import 'package:career_ally/features/user_auth/presentation/pages/login_page.dart';
// import 'package:career_ally/features/user_auth/presentation/widgets/form_container_widget.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:lottie/lottie.dart';
//
// import '../../firebase_auth_implementation/verify_email_page.dart';
//
// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});
//
//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }
//
// class _SignupPageState extends State<SignupPage> {
//   final FirebaseAuthService _auth = FirebaseAuthService();
//
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isSigningUp = false;
//
//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   String _selectedRole = 'student'; // Default role
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Lottie.asset(
//                 'assets/login_animation.json', // Replace with your signup animation
//                 height: 150,
//                 width: 150,
//                 repeat: true,
//               ),
//               SizedBox(height: 20),
//               Text(
//                 "Create Account",
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 10),
//               Text(
//                 "Sign up to get started!",
//                 style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                 textAlign: TextAlign.center,
//               ),
//
//               // *** INSERT THIS CODE HERE ***
//               SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Row(
//                     children: [
//                       Radio(
//                         value: 'student',
//                         groupValue: _selectedRole,
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedRole = value!;
//                           });
//                         },
//                       ),
//                       Text("Student"),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Radio(
//                         value: 'tpo',
//                         groupValue: _selectedRole,
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedRole = value!;
//                           });
//                         },
//                       ),
//                       Text("TPO"),
//                     ],
//                   ),
//                 ],
//               ),
//               // *** END OF INSERTION ***
//
//               SizedBox(height: 20),  // Adjusted spacing
//
//               FormContainerWidget(
//                 controller: _usernameController,
//                 hintText: "Username",
//                 isPasswordField: false,
//                 prefixIcon: Icons.person,
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               FormContainerWidget(
//                 controller: _emailController,
//                 hintText: "Email",
//                 isPasswordField: false,
//                 prefixIcon: Icons.email,
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               FormContainerWidget(
//                 controller: _passwordController,
//                 hintText: "Password",
//                 isPasswordField: true,
//                 prefixIcon: Icons.lock,
//               ),
//               SizedBox(
//                 height: 30,
//               ),
//               ElevatedButton(
//                 onPressed: _isSigningUp ? null : _signUp,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   padding: EdgeInsets.symmetric(vertical: 15),
//                   textStyle: TextStyle(fontSize: 18),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 child: _isSigningUp
//                     ? Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SpinKitThreeBounce(color: Colors.white, size: 20),
//                     SizedBox(width: 10),
//                     Text("Creating...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                   ],
//                 )
//                     : Text(
//                   "Sign Up",
//                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text("Already have an account?", style: TextStyle(color: Colors.grey[700])),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(builder: (context) => LoginPage()),
//                             (route) => false,
//                       );
//                     },
//                     child: Text(
//                       "Login",
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
//   void _signUp() async {
//     setState(() {
//       _isSigningUp = true;
//     });
//     String username = _usernameController.text.trim();
//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();
//
//     if (username.isEmpty || email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Please enter all fields.")),
//       );
//       setState(() {
//         _isSigningUp = false;
//       });
//       return;
//     }
//
//     try {
//       // ***  PASS THE SELECTED ROLE HERE ***
//       User? user = await _auth.signUpWithEmailAndPassword(email, password, _selectedRole,username); // Pass the role
//       setState(() {
//         _isSigningUp = false;
//       });
//
//       if (user != null) {
//         // Send verification email
//         try {
//           await user.sendEmailVerification();
//           print("Verification email sent.");
//
//           // Navigate to the Verify Email page
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => VerifyEmailPage()),
//           );
//
//         } catch (e) {
//           print("Error sending verification email: $e");
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Error sending verification email: ${e.toString()}")),
//           );
//         }
//       } else {
//         print("error occurred");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to create user."),),
//         );
//       }
//     } catch (e) {
//       print("Error signing up: $e");
//       setState(() {
//         _isSigningUp = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error signing up: ${e.toString()}")),
//       );
//     }
//   }
// }
import 'package:career_ally/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:career_ally/features/user_auth/presentation/pages/login_page.dart';
import 'package:career_ally/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

// Import the validators and verification page
import '../utils/validators.dart';
import '../../firebase_auth_implementation/verify_email_page.dart';
// Import cloud functions (if needed for claims later, keep the import)
import 'package:cloud_functions/cloud_functions.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final FirebaseFunctions _functions = FirebaseFunctions.instance; // Instance for Cloud Functions

  // Add a GlobalKey for the Form
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigningUp = false;
  String _selectedRole = 'student'; // Default role

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          // Wrap the Column with a Form widget
          child: Form(
            key: _formKey, // Assign the key to the Form
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

                // Role Selection Radios (Keep as is)
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(children: [
                      Radio<String>( value: 'student', groupValue: _selectedRole, onChanged: (v) => setState(()=> _selectedRole=v!),),
                      Text("Student"),
                    ]),
                    Row(children: [
                      Radio<String>( value: 'tpo', groupValue: _selectedRole, onChanged: (v) => setState(()=> _selectedRole=v!)),
                      Text("TPO"),
                    ]),
                  ],
                ),

                SizedBox(height: 20),

                // --- Username Field with Validation ---
                FormContainerWidget(
                  controller: _usernameController,
                  hintText: "Username",
                  isPasswordField: false,
                  prefixIcon: Icons.person,
                  validator: Validators.validateUsername, // Use validator
                ),
                SizedBox(height: 20),

                // --- Email Field with Validation ---
                FormContainerWidget(
                  controller: _emailController,
                  hintText: "Email",
                  isPasswordField: false,
                  prefixIcon: Icons.email,
                  inputType: TextInputType.emailAddress, // Set keyboard type
                  validator: Validators.validateEmail, // Use validator
                ),
                SizedBox(height: 20),

                // --- Password Field with Validation ---
                FormContainerWidget(
                  controller: _passwordController,
                  hintText: "Password",
                  isPasswordField: true,
                  prefixIcon: Icons.lock,
                  validator: Validators.validatePassword, // Use password validator
                ),
                SizedBox(height: 30),

                // --- Sign Up Button ---
                ElevatedButton(
                  onPressed: _isSigningUp ? null : _signUp, // Call _signUp
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSigningUp
                      ? Row( /* ... loading indicator ... */
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitThreeBounce(color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text("Creating...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  )
                      : Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 20),

                // --- Login Link (Keep as is) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: TextStyle(color: Colors.grey[700])),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()),(route) => false,),
                      child: Text("Login", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Modified _signUp Method ---
  void _signUp() async {
    // 1. Validate the form using the GlobalKey
    if (!_formKey.currentState!.validate()) {
      // If validation fails, FormFields will show error messages automatically
      return; // Don't proceed if form is not valid
    }

    // 2. If valid, proceed with signup logic
    setState(() { _isSigningUp = true; });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text; // Get password (no trim needed usually)

    try {
      User? user = await _auth.signUpWithEmailAndPassword(email, password, _selectedRole, username);
      // Keep the call to set custom claims if using Cloud Functions
      if (user != null) {
        await _callSetCustomClaims(user.uid, _selectedRole, username); // Ensure this function exists and works
      }


      setState(() { _isSigningUp = false; });

      if (user != null) {
        // Send verification email (already handled in your original code)
        // Navigate to Verify Email page
        if (!user.emailVerified) { // Only navigate if not already verified (unlikely on signup)
          await user.sendEmailVerification();
          print("Verification email sent.");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VerifyEmailPage()),
          );
        } else {
          // Should ideally not happen right after signup, but handle it
          print("User email was already verified?");
          Navigator.pushReplacementNamed(context, "/home"); // Or login?
        }

      } else {
        print("Error occurred during signup (user is null)");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create user account.")),
        );
      }
    } catch (e) {
      print("Error signing up: $e");
      setState(() { _isSigningUp = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        // Provide more specific error message if possible
        SnackBar(content: Text("Error signing up: ${e.toString()}")),
      );
    }
  }

  // --- Keep the _callSetCustomClaims function if you use it ---
  Future<void> _callSetCustomClaims(String uid, String role, String username) async {
    try {
      // Ensure the function name here ('setCustomClaims') matches exactly
      // the name you gave your deployed Cloud Function.
      HttpsCallable callable = _functions.httpsCallable('setCustomClaims');
      print('Calling setCustomClaims for UID: $uid with role: $role username: $username');
      final results = await callable.call(<String, dynamic>{
        // Ensure the Cloud Function expects 'role' and 'username' in the data payload
        'role': role,
        'username': username,
        // 'uid': uid, // Cloud Function gets UID from context.auth.uid, not usually passed in data
      });
      print('Cloud function result: ${results.data}');
    } catch (e) {
      print('Error calling setCustomClaims function: $e');
      // Show error to user if claim setting fails, as it's important for role
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to set user role properties. Please contact support if issues persist.')),
      );
      // Decide if signup should proceed if claims fail - depends on your logic
    }
  }


} // End of _SignupPageState
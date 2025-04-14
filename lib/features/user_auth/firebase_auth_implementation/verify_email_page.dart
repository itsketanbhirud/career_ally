import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;

  @override
  void initState() {
    super.initState();

    // Initially check if the user is already verified.
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      // Poll to check email verification status.
      Future.delayed(Duration(seconds: 5), () => checkEmailVerified());
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 60));
      setState(() => canResendEmail = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending verification email: $e')),
      );
    }
  }

  Future checkEmailVerified() async {
    // Call after email verification
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email successfully verified!')),
      );
      //  Navigate to home page or next appropriate screen.
      Navigator.pushNamed(context, "/login");
    } else {
      // Schedule another check after a delay
      Future.delayed(Duration(seconds: 5), () => checkEmailVerified());
    }
  }


  @override
  Widget build(BuildContext context) => isEmailVerified
      ? Scaffold(  // Replace with your actual home page/next screen
    appBar: AppBar(title: const Text('Verified!')),
    body: const Center(child: Text('Email is verified!')),
  )
      : Scaffold(
    appBar: AppBar(title: const Text('Verify Email')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'A verification email has been sent to your email address.',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: canResendEmail ? sendVerificationEmail : null,
            child: const Text('Resend Email'),
          ),
          const SizedBox(height: 20),
          Text(
            'Please check your email (including spam folder) and click the link to verify your address.  The app will automatically check for verification.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    ),
  );
}
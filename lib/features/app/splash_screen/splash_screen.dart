// import 'package:flutter/material.dart';
//
//  class SplashScreen extends StatefulWidget {
//    final Widget? child;
//    const SplashScreen({super.key, this.child});
//
//    @override
//    State<SplashScreen> createState() => _SplashScreenState();
//  }
//
//  class _SplashScreenState extends State<SplashScreen> {
//
//    @override
//   void initState() {
//     Future.delayed(Duration(seconds:3), (){
// Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>widget.child!), (route)=>false);
//     });
//     super.initState();
//   }
//    @override
//    Widget build(BuildContext context) {
//      return Scaffold(
//        body: Center(
//          child: Text("Career Ally", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
//        ),
//      );
//    }
//  }
//
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final Widget? child;

  const SplashScreen({Key? key, this.child}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => widget.child!),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(  // Center the logo and tagline
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Image.asset(
                      'assets/logo.png',
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Learn. Connect. Succeed.",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Copyright Text at the Bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                "© 2025 KK. All rights reserved.",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
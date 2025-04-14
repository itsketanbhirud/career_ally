// import 'package:flutter/material.dart';
// import 'connections.dart';
// import 'opportunities.dart';
// import 'profile.dart';
// import 'home_redirect/tpo_updates.dart';
// import 'home_redirect/alumni_guidance.dart';
// import 'home_redirect/upcoming_drives.dart';
// import 'home_redirect/placement_resources.dart';
// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   int _currentIndex = 0;
//   final PageController _pageController = PageController();
//
//   final List<Widget> _pages = [
//     HomeScreen(),
//     ConnectionsScreen(),
//     OpportunitiesScreen(),
//     ProfileScreen(),
//   ];
//
//   void _onPageChanged(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }
//
//   void _onTabTapped(int index) {
//     _pageController.animateToPage(
//       index,
//       duration: Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PageView(
//         controller: _pageController,
//         children: _pages,
//         onPageChanged: _onPageChanged,
//         physics: _currentIndex == 0
//             ? RestrictedScrollPhysics(allowForward: true, allowBackward: false) // Allow forward, block backward
//             : _currentIndex == _pages.length - 1
//             ? RestrictedScrollPhysics(allowForward: false, allowBackward: true) // Allow backward, block forward
//             : BouncingScrollPhysics(), // Normal scrolling for other tabs
//       ),
//       bottomNavigationBar: Theme(
//         data: Theme.of(context).copyWith(
//           splashColor: Colors.transparent,
//           highlightColor: Colors.transparent,
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           selectedItemColor: Colors.deepPurple,
//           unselectedItemColor: Colors.grey,
//           showSelectedLabels: false,
//           showUnselectedLabels: false,
//           onTap: _onTabTapped,
//           type: BottomNavigationBarType.fixed,
//           items: [
//             BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
//             BottomNavigationBarItem(icon: Icon(Icons.people), label: ''),
//             BottomNavigationBarItem(icon: Icon(Icons.business_center), label: ''),
//             BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Custom Scroll Physics Implementation
// class RestrictedScrollPhysics extends ScrollPhysics {
//   final bool allowForward;
//   final bool allowBackward;
//
//   const RestrictedScrollPhysics({
//     required this.allowForward,
//     required this.allowBackward,
//     ScrollPhysics? parent,
//   }) : super(parent: parent);
//
//   @override
//   RestrictedScrollPhysics applyTo(ScrollPhysics? ancestor) {
//     return RestrictedScrollPhysics(
//       allowForward: allowForward,
//       allowBackward: allowBackward,
//       parent: buildParent(ancestor),
//     );
//   }
//
//   @override
//   double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
//     if (!allowForward && offset < 0) {
//       // Block forward swiping
//       return 0.0;
//     }
//     if (!allowBackward && offset > 0) {
//       // Block backward swiping
//       return 0.0;
//     }
//     return offset;
//   }
// }
//
// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Career Ally',
//           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: Colors.deepPurple,
//         // iconTheme: IconThemeData(color: Colors.white),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Text(
//                 'Welcome to Career Ally!',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//             ),
//             SizedBox(height: 20),
//             Expanded(
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 children: [
//                   _buildCard(Icons.school, 'TPO Updates', context, TPOUpdatesScreen()),
//                   _buildCard(Icons.people, 'Alumni Guidance', context, AlumniGuidanceScreen()),
//                   _buildCard(Icons.work, 'Placement Resources', context, PlacementResourcesScreen()),
//                   _buildCard(Icons.event, 'Upcoming Drives', context, UpcomingDrivesScreen()),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCard(IconData icon, String title, BuildContext context, Widget screen) {
//     return GestureDetector(
//       onTap: () {
//         // Navigate to the specific screen when the card is tapped
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => screen),
//         );
//       },
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         elevation: 4,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 40, color: Colors.deepPurple),
//               SizedBox(height: 10),
//               Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'connections.dart';
import 'opportunities.dart';
import 'profile.dart';
import 'home_redirect/tpo_updates.dart';
import 'home_redirect/alumni_guidance.dart';
import 'home_redirect/upcoming_drives.dart';
import 'home_redirect/placement_resources.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userRole = userDoc.get('role');
            _isLoading = false;
          });
        } else {
          print("User document not found");
          setState(() {
            _userRole = null;
            _isLoading = false;
          });
        }
      } else {
        print("User not logged in");
        setState(() {
          _userRole = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading user role: $e");
      setState(() {
        _userRole = null;
        _isLoading = false;
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define pages based on user role
    List<Widget> pages;
    if (_userRole == 'tpo') {
      pages = [
        TpoHomeScreen(), //TPO Home Screen
        ConnectionsScreen(),
        OpportunitiesScreen(),
        ProfileScreen(),
      ];
    } else {
      // Default to student layout
      pages = [
        StudentHomeScreen(), //Student Home Screen
        ConnectionsScreen(),
        OpportunitiesScreen(),
        ProfileScreen(),
      ];
    }
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userRole == null
          ? Center(child: Text("Error: Could not load user role."))
          : PageView(
        controller: _pageController,
        children: pages,
        onPageChanged: _onPageChanged,
        physics: _currentIndex == 0
            ? RestrictedScrollPhysics(allowForward: true, allowBackward: false)
            : _currentIndex == pages.length - 1
            ? RestrictedScrollPhysics(allowForward: false, allowBackward: true)
            : BouncingScrollPhysics(),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.business_center), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
        ),
      ),
    );
  }
}

// Custom Scroll Physics Implementation
class RestrictedScrollPhysics extends ScrollPhysics {
  final bool allowForward;
  final bool allowBackward;

  const RestrictedScrollPhysics({
    required this.allowForward,
    required this.allowBackward,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  RestrictedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return RestrictedScrollPhysics(
      allowForward: allowForward,
      allowBackward: allowBackward,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (!allowForward && offset < 0) {
      // Block forward swiping
      return 0.0;
    }
    if (!allowBackward && offset > 0) {
      // Block backward swiping
      return 0.0;
    }
    return offset;
  }
}

//TPO Home Screen
class TpoHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Career Ally',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Welcome to Career Ally!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildCard(Icons.announcement, 'Manage Updates', context, TPOUpdatesScreen()),
                  _buildCard(Icons.people, 'Manage Alumni', context, AlumniGuidanceScreen()),
                  _buildCard(Icons.library_books, 'Manage Resources', context, PlacementResourcesScreen()),
                  _buildCard(Icons.event, 'Manage Drives', context, UpcomingDrivesScreen()),
                  // Add TPO specific options here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, BuildContext context, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.deepPurple),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Student Home Screen
class StudentHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Career Ally',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Welcome to Career Ally!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildCard(Icons.school, 'TPO Updates', context, TPOUpdatesScreen()),
                  _buildCard(Icons.people, 'Alumni Guidance', context, AlumniGuidanceScreen()),
                  _buildCard(Icons.work, 'Placement Resources', context, PlacementResourcesScreen()),
                  _buildCard(Icons.event, 'Upcoming Drives', context, UpcomingDrivesScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, BuildContext context, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.deepPurple),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
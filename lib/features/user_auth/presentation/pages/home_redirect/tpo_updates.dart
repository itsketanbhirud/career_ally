// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // For date formatting (add intl package to pubspec.yaml)
// import '../../services/firestore_service.dart'; // Adjust import path
// import '../../models/tpo_update_model.dart'; // Adjust import path
// class TPOUpdatesScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('TPO Updates', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.deepPurple,
//         iconTheme: IconThemeData(color: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             _buildUpdateCard(
//               "Important Notice Regarding Placement Drive",
//               "All students are requested to submit their resumes by 5 PM tomorrow.  Late submissions will not be considered.",
//               "2024-01-26",
//               "Ms. P.J.Hajare", // TPO Name
//             ),
//             _buildUpdateCard(
//               "Guest Lecture by Industry Expert",
//               "A guest lecture on 'Future Trends in Technology' will be held on January 28th at 10 AM in the Auditorium.",
//               "2024-01-24",
//               "Ms. P.J.Hajare", // TPO Name
//             ),
//             _buildUpdateCard(
//               "Pre-Placement Training Session",
//               "A pre-placement training session focusing on aptitude tests will be conducted on January 27th. Register soon!",
//               "2024-01-23",
//               "Ms. P.J.Hajare", // TPO Name
//             ),
//             _buildUpdateCard(
//               "Reminder: Mock Interview Session",
//               "Don't forget to attend the mock interview session scheduled for today at 2 PM.  Be prepared!",
//               "2024-01-22",
//               "Ms. P.J.Hajare", // TPO Name
//             ),
//             // Add more update cards as needed
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUpdateCard(
//       String title, String description, String date, String tpoName) {
//     return Card(
//       elevation: 3,
//       margin: EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.deepPurple,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               description,
//               style: TextStyle(fontSize: 16, color: Colors.grey[800]),
//             ),
//             SizedBox(height: 12),
//             Row(
//               mainAxisAlignment:
//                   MainAxisAlignment.spaceBetween, // Changed to spaceBetween
//               children: [
//                 Text(
//                   "By: $tpoName", // Display TPO Name
//                   style: TextStyle(fontSize: 14, color: Colors.blueGrey),
//                 ),
//                 Text(
//                   date,
//                   style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting (add intl package to pubspec.yaml)
import '../../services/firestore_service.dart'; // Adjust import path
import '../../models/tpo_update_model.dart'; // Adjust import path

class TPOUpdatesScreen extends StatefulWidget {
  @override
  _TPOUpdatesScreenState createState() => _TPOUpdatesScreenState();
}

class _TPOUpdatesScreenState extends State<TPOUpdatesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // --- Optional: Add functionality for TPO to post ---
  // final TextEditingController _titleController = TextEditingController();
  // final TextEditingController _descController = TextEditingController();
  // final FirebaseAuth _auth = FirebaseAuth.instance; // If needed for current user UID/Name
  // String? _tpoName; // Store TPO name if needed

  // @override
  // void initState() {
  //   super.initState();
  //   _loadTpoName(); // Load TPO name if allowing posting from here
  // }

  // Future<void> _loadTpoName() async {
  //   // Fetch TPO name from their profile if needed for posting
  //   // ... implementation using FirestoreService ...
  // }

  // @override
  // void dispose() {
  //   _titleController.dispose();
  //   _descController.dispose();
  //   super.dispose();
  // }

  // void _showAddUpdateDialog() {
  //    // ... Implementation for showing a dialog for TPO to add update ...
  //    // Needs role check to only show button/dialog for TPO users
  // }
  // --- End of optional TPO posting section ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Keep AppBar as is, or add back button if needed
        title: Text('TPO Updates', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        // automaticallyImplyLeading: false, // Remove or set true if navigation stack exists
        iconTheme: IconThemeData(color: Colors.white), // Ensure back button is white if shown
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<List<TpoUpdate>>(
        stream: _firestoreService.getTpoUpdatesStream(), // Use the stream from the service
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // Handle error state
          if (snapshot.hasError) {
            print("Error fetching TPO updates: ${snapshot.error}");
            return Center(child: Text('Error loading updates: ${snapshot.error}'));
          }
          // Handle empty state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No updates available right now.'));
          }

          // Display the list of updates
          final updates = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: updates.length,
            itemBuilder: (context, index) {
              final update = updates[index];
              return _buildUpdateCard(
                update.title,
                update.description,
                // Format the Timestamp
                DateFormat('yyyy-MM-dd hh:mm a').format(update.postedAt.toDate()),
                update.postedByName,
              );
            },
          );
        },
      ),
      // --- Optional: Floating Action Button for TPO to add updates ---
      // floatingActionButton: _userRole == 'tpo' // Check user role if available
      //     ? FloatingActionButton(
      //         onPressed: _showAddUpdateDialog,
      //         child: Icon(Icons.add),
      //         backgroundColor: Colors.deepPurple,
      //       )
      //     : null,
      // --- End of optional FAB ---
    );
  }

  // Keep the _buildUpdateCard widget as is
  Widget _buildUpdateCard(
      String title, String description, String date, String tpoName) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Allow TPO name to wrap if long
                  child: Text(
                    "By: $tpoName",
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey, fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 10), // Add spacing
                Text(
                  date,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class TPOUpdatesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TPO Updates', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildUpdateCard(
              "Important Notice Regarding Placement Drive",
              "All students are requested to submit their resumes by 5 PM tomorrow.  Late submissions will not be considered.",
              "2024-01-26",
              "Ms. P.J.Hajare", // TPO Name
            ),
            _buildUpdateCard(
              "Guest Lecture by Industry Expert",
              "A guest lecture on 'Future Trends in Technology' will be held on January 28th at 10 AM in the Auditorium.",
              "2024-01-24",
              "Ms. P.J.Hajare", // TPO Name
            ),
            _buildUpdateCard(
              "Pre-Placement Training Session",
              "A pre-placement training session focusing on aptitude tests will be conducted on January 27th. Register soon!",
              "2024-01-23",
              "Ms. P.J.Hajare", // TPO Name
            ),
            _buildUpdateCard(
              "Reminder: Mock Interview Session",
              "Don't forget to attend the mock interview session scheduled for today at 2 PM.  Be prepared!",
              "2024-01-22",
              "Ms. P.J.Hajare", // TPO Name
            ),
            // Add more update cards as needed
          ],
        ),
      ),
    );
  }

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
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Changed to spaceBetween
              children: [
                Text(
                  "By: $tpoName", // Display TPO Name
                  style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                ),
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

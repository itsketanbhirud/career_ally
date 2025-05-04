import 'package:flutter/material.dart';

class UpcomingDrivesScreen extends StatelessWidget {
  const UpcomingDrivesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Drives', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDriveCard(
              "Google",
              "Software Engineer",
              "2024-02-15",
              "Open to all CS/IT graduates. Apply before Feb 10th.",
              "https://careers.google.com/students/",
            ),
            _buildDriveCard(
              "Microsoft",
              "Associate Software Engineer",
              "2024-02-22",
              "For students with strong problem-solving skills. Register by Feb 18th.",
              "https://careers.microsoft.com/students",
            ),
            _buildDriveCard(
              "Amazon",
              "Data Scientist",
              "2024-03-01",
              "Looking for candidates with a background in machine learning. Apply by Feb 25th.",
              "https://www.amazon.jobs/en/teams/university-recruiting",
            ),
            _buildDriveCard(
              "Deloitte",
              "Business Analyst",
              "2024-03-08",
              "Open to all graduates with strong analytical skills. Apply before March 1st.",
              "https://www2.deloitte.com/us/en/careers/students.html",
            ),
            // Add more drive cards as needed
          ],
        ),
      ),
    );
  }

  Widget _buildDriveCard(String companyName, String jobTitle, String date,
      String description, String applyLink) {
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
              companyName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 8),
            Text(
              jobTitle,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            SizedBox(height: 8),
            Text(
              "Date: $date",
              style: TextStyle(fontSize: 14, color: Colors.blueGrey),
            ),
            SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement functionality to open the apply link
                    // You'll need url_launcher for this
                    // Example: launchUrl(Uri.parse(applyLink));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Apply Now"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
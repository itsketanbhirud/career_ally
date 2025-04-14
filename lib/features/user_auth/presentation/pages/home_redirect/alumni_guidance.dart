import 'package:flutter/material.dart';

class AlumniGuidanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guidance', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildAlumniCard(
              "Aditya Verma",
              "Software Engineer at Google",
              "aditya.verma@google.com",
              "I can provide guidance on cracking technical interviews and building a strong resume.",
            ),
            _buildAlumniCard(
              "Priya Sharma",
              "Product Manager at Microsoft",
              "priya.sharma@microsoft.com",
              "Happy to help with product management career paths and navigating the tech industry.",
            ),
            _buildAlumniCard(
              "Rohan Gupta",
              "Data Scientist at Amazon",
              "rohan.gupta@amazon.com",
              "I can offer advice on data science skills, projects, and interview preparation.",
            ),
            _buildAlumniCard(
              "Sneha Patel",
              "Business Analyst at Deloitte",
              "sneha.patel@deloitte.com",
              "Offering guidance on business analysis, consulting roles, and professional development.",
            ),
            // Add more alumni cards as needed
          ],
        ),
      ),
    );
  }

  Widget _buildAlumniCard(
      String name, String jobTitle, String email, String description) {
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
              name,
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
              email,
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
                    // Implement functionality to contact the alumni (e.g., open email app)
                    // You'll need a package like url_launcher for this:
                    // https://pub.dev/packages/url_launcher
                    // Example: launch("mailto:$email");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // Button color
                    foregroundColor: Colors.white, // Text color
                  ),
                  child: Text("Contact"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
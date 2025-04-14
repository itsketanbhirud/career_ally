// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class PlacementResourcesScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Placement Resources', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.deepPurple,
//         iconTheme: IconThemeData(color: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             _buildResourceCard(
//               context, // Pass the build context here
//               "GeeksforGeeks",
//               "Coding Practice and Interview Preparation",
//               "https://www.geeksforgeeks.org/",
//             ),
//             _buildResourceCard(
//               context, // Pass the build context here
//               "LeetCode",
//               "Coding Challenges and Interview Questions",
//               "https://leetcode.com/",
//             ),
//             _buildResourceCard(
//               context, // Pass the build context here
//               "InterviewBit",
//               "Interview Preparation Platform",
//               "https://www.interviewbit.com/",
//             ),
//             _buildResourceCard(
//               context, // Pass the build context here
//               "Glassdoor",
//               "Company Reviews, Salaries, and Interview Questions",
//               "https://www.glassdoor.com/",
//             ),
//             _buildResourceCard(
//               context, // Pass the build context here
//               "CareerCup",
//               "Interview Questions and Solutions",
//               "http://www.careercup.com/",
//             ),
//             // Add more resource cards as needed
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildResourceCard(BuildContext context, String title, String description, String url) {
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
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 ElevatedButton(
//                   onPressed: () async {
//                     final Uri resourceUrl = Uri.parse(url);
//                     if (await canLaunchUrl(resourceUrl)) {
//                       await launchUrl(resourceUrl);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Could not launch $url')),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepPurple,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: Text("Visit"),
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
import 'package:url_launcher/url_launcher.dart'; // For opening links

class PlacementResourcesScreen extends StatelessWidget {
  // Static/mock data for placement resources
  final List<Map<String, String>> resources = [
    {
      'title': 'Resume Template',
      'description': 'A professional resume template for freshers.',
      'action': 'Download',
      'url': 'https://example.com/resume-template.pdf',
    },
    {
      'title': 'Interview Tips',
      'description': 'Top 50 interview questions and answers.',
      'action': 'View',
      'url': 'https://example.com/interview-tips',
    },
    {
      'title': 'Company Profiles',
      'description': 'Detailed profiles of top companies.',
      'action': 'View',
      'url': 'https://example.com/company-profiles',
    },
    {
      'title': 'Cover Letter Guide',
      'description': 'How to write an effective cover letter.',
      'action': 'Download',
      'url': 'https://example.com/cover-letter-guide.pdf',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Placement Resources',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), // White text
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.white), // White back arrow
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1, // Adjust aspect ratio for consistent height
        ),
        padding: EdgeInsets.all(16),
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final resource = resources[index];
          return GestureDetector(
            onTap: () {
              // Navigate to a new page when the card is tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResourceDetailScreen(resource: resource),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with ellipsis
                    Text(
                      resource['title']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      maxLines: 1, // Allow two lines for longer titles
                      overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                    ),
                    SizedBox(height: 4),
                    // Description with ellipsis
                    Text(
                      resource['description']!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 2, // Limit to three lines
                      overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                    ),
                    Spacer(), // Pushes the button to the bottom
                    // Action Button (Always at the Bottom)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: () {
                          // Open the URL when the button is pressed
                          _launchURL(resource['url']!);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          resource['action']!,
                          style: TextStyle(fontSize: 14, color: Colors.white), // White text
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Function to launch URLs (for buttons like "Download" or "View")
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

// New Screen to Display Full Details
class ResourceDetailScreen extends StatelessWidget {
  final Map<String, String> resource;

  ResourceDetailScreen({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(resource['title']!,style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resource['title']!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 16),
            Text(
              resource['description']!,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Open the URL when the button is pressed
                _launchURL(resource['url']!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                resource['action']!,
                style: TextStyle(fontSize: 14, color: Colors.white), // White text
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to launch URLs (for buttons like "Download" or "View")
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
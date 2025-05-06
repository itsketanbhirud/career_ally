// lib/screens/home_redirect/drive_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/upcoming_drive_model.dart'; // Adjust path

class DriveDetailScreen extends StatelessWidget {
  final UpcomingDrive drive;

  const DriveDetailScreen({Key? key, required this.drive}) : super(key: key);

  // Replicated robust launch function (Consider moving to a shared utility file)
  Future<void> _launchURL(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No application link provided.')));
      return;
    }
    final String trimmedUrl = url.trim();
    Uri? uri;
    try {
      String urlToParse = trimmedUrl;
      if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) {
        urlToParse = 'https://$trimmedUrl';
      }
      uri = Uri.parse(urlToParse);
    } catch (e) { /* ... error handling ... */ if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid URL format: $trimmedUrl'))); return; }
    if (!uri.scheme.startsWith('http')) { /* ... error handling ... */ if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot launch non-web URL: $trimmedUrl'))); return; }
    bool canLaunch = false;
    try { canLaunch = await canLaunchUrl(uri); } catch(e) { /* ... error handling ... */ return;}
    if (!canLaunch) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $trimmedUrl'))); }
    else { try { await launchUrl(uri, mode: LaunchMode.externalApplication); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to launch URL: ${e.toString()}'))); } }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(drive.companyName, style: TextStyle(color: Colors.white)), // Show company name in title
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white), // Back button color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              drive.companyName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade800),
            ),
            SizedBox(height: 8),
            Text(
              drive.jobTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
            ),
            SizedBox(height: 16),
            _buildDetailRow(Icons.calendar_today, "Drive Date:", DateFormat('EEEE, MMM d, yyyy').format(drive.driveDate.toDate())),
            Divider(height: 20),

            Text(
              "Description & Eligibility:",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            SelectableText(
              drive.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
            SizedBox(height: 16),


            // Display Required Technologies if available
            if (drive.requiredTechnologies != null && drive.requiredTechnologies!.isNotEmpty) ...[
              Divider(height: 20),
              Text(
                "Key Technologies/Skills:",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8.0, runSpacing: 4.0,
                children: drive.requiredTechnologies!.map((tech) => Chip(
                  label: Text(tech),
                  backgroundColor: Colors.deepPurple.shade50,
                )).toList(),
              ),
              SizedBox(height: 16),
            ],

            Divider(height: 20),
            _buildDetailRow(Icons.person_outline, "Announced By:", drive.postedByName),
            _buildDetailRow(Icons.access_time, "Posted On:", DateFormat('MMM d, yyyy').format(drive.postedAt.toDate())),
            SizedBox(height: 24),

            // Apply Button
            if (drive.applyLink != null && drive.applyLink!.isNotEmpty)
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.link, color: Colors.white),
                  label: Text('Apply / More Details', style: TextStyle(fontSize: 15, color: Colors.white)),
                  onPressed: () => _launchURL(context, drive.applyLink!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper widget for displaying detail rows with icons
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.deepPurple.shade300),
          SizedBox(width: 10),
          Text(
            "$label ",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
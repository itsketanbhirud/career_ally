import 'package:flutter/material.dart';

class OpportunitiesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Opportunities',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        // iconTheme: IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: Icon(Icons.work, color: Colors.deepPurple),
              title: Text('Opportunity ${index + 1}'),
              subtitle: Text('Company: Example Corp\nLocation: Remote'),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
              onTap: () {
                // Add navigation to detailed opportunity page here
              },
            ),
          );
        },
      ),
    );
  }
}

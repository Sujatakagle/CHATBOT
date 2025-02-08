import 'package:flutter/material.dart';
import 'faq_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {"title": "General Questions", "category": "general"},
    {"title": "Charging Related", "category": "charging"},
    {"title": "Payment & Billing", "category": "payment"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Help & Support")),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(categories[index]["title"]!, style: TextStyle(fontSize: 18)),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FAQScreen(category: categories[index]["category"]!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

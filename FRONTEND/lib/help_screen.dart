import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'chatbot_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  @override
  _HelpCenterScreenState createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  late IO.Socket socket;
  List<Map<String, String>> categories = [];

  @override
  void initState() {
    super.initState();
    connectToSocket();
  }

  void connectToSocket() {
    socket = IO.io("ws://192.168.1.18:5000", {
      "transports": ["websocket"],
      "autoConnect": false,
    });

    socket.connect();

    socket.onConnect((_) {
      socket.emit("getCategories");
    });

    socket.on("categories", (data) {
      setState(() {
        categories = List<Map<String, String>>.from(
          data.map((category) => {
            "title": category["category"].toString(),
            "category": category["category"].toString(),
          }),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background to black
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: Colors.black, // Black app bar
        foregroundColor: Colors.white, // White text and icons
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Simple Welcome Text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    "We're here to help",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Find the answers to your questions.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70, // Slightly faded white
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // FAQ Header
            Card(
              color: Colors.black, // Black card
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white), // White border
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "FAQ's (Select a Help Topic)",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // White text
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Big White Card containing all categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                color: Colors.black, // Black card
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white), // White border
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: categories.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.help_outline,
                              color: Colors.white, // White icon
                            ),
                            title: Text(
                              categories[index]["title"]!,
                              style: const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FAQScreen(category: categories[index]["category"]!),
                                ),
                              );
                            },
                          ),
                          if (index < categories.length - 1)
                            const Divider(color: Colors.white), // White divider
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}

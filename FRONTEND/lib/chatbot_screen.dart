import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'help_screen.dart';

class FAQScreen extends StatefulWidget {
  final String category;
  FAQScreen({required this.category});

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  late IO.Socket socket;
  List<Map<String, dynamic>> allQuestions = [];
  Map<String, dynamic>? selectedChat;
  bool isTyping = false;
  bool showOptions = false;
  bool showMessage = false;
  TextEditingController messageController = TextEditingController();

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
      print("Connected to Socket.IO server");
      socket.emit("getFaq", widget.category);
    });

    socket.on("faqList", (data) {
      setState(() {
        allQuestions = List<Map<String, dynamic>>.from(
          data.map((faq) =>
          {
            "question": faq["question"].toString(),
            "answer": "",
            "timeAsked": "",
            "timeAnswered": "",
          }),
        );
      });
    });

    socket.on("answer", (data) {
      if (selectedChat != null &&
          selectedChat!["question"] == data["question"]) {
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            isTyping = false;
            selectedChat = {
              ...selectedChat!,
              "answer": data["answer"].toString(),
              "timeAnswered": DateFormat('hh:mm a').format(DateTime.now()),
            };
            showOptions = true; // Enable options after receiving the answer
          });
        });
      }
    });


    socket.onDisconnect((_) => print("Disconnected from server"));
  }

  @override
  void dispose() {
    socket.dispose();
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() {
    String userMessage = messageController.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      isTyping = true;
      selectedChat = {
        "question": userMessage,
        "answer": "",
        "timeAsked": DateFormat('hh:mm a').format(DateTime.now()),
      };
      showOptions = false;
      showMessage = false;
    });

    socket.emit(
        "getAnswer", {"category": widget.category, "question": userMessage});
    messageController.clear();
  }

  void fetchAnswer(int index) {
    setState(() {
      isTyping = true;
      selectedChat = Map.from(allQuestions[index]);
      selectedChat!["timeAsked"] = DateFormat('hh:mm a').format(DateTime.now());
      showOptions = false; // Ensure it resets when fetching a new answer
      showMessage = false;
    });

    socket.emit("getAnswer",
        {"category": widget.category, "question": selectedChat!["question"]});
  }

  void resetChat() {
    setState(() {
      selectedChat = null;
      showOptions = false;
      showMessage = false;
    });
  }

  void hideOptions() {
    setState(() {
      showMessage = true;
    });
  }

  Widget chatBubble(
      {required String text, required bool isUser, String? time}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment
            .start,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.support_agent, color: Colors.black),
            ),
          Flexible(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.grey[800] : Colors.grey[900],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: isUser ? Radius.circular(12) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(color: Colors.white),
                  ),
                  if (time != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        time,
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isUser)
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
        ],
      ),
    );
  }

  Widget loadingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) =>
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    height: 6,
                    width: 6,
                    decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                  ),
                ))),
      ),
    );
  }


  Widget optionsWidget() {
    return Column(
      children: [
        if (!showMessage) ...[
          SizedBox(height: 10),
          Text(
            "Would you like to ask something else?",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: resetChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  // Soft muted gray
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: BeveledRectangleBorder(),
                  // No rounded corners
                  elevation: 2,
                ),
                child: Text("Yes, I do", style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: hideOptions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  // Slightly muted blue-gray
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: BeveledRectangleBorder(),
                  // No rounded corners
                  elevation: 2,
                ),
                child: Text("No, thanks", style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
        if (showMessage) ...[
          SizedBox(height: 20),
          Text(
            "Great to hear! That we could resolve your query",
            textAlign: TextAlign.center, // Align text in the center
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color: Colors.white, // More neutral color
              fontFamily: 'Roboto', // Change to any available font family
            ),
          ),

          SizedBox(height: 10),


        ],
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true, // Prevents overflow when keyboard appears
      appBar: AppBar(
        title: Text(widget.category, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                todayDate,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.white70),
              ),
            ),

            chatBubble(
              text: "Hi! I'm your assistant. How can I help?",
              isUser: false,
              time: DateFormat('hh:mm a').format(DateTime.now()),
            ),
            SizedBox(height: 10),

            // Wrapping content in Expanded to prevent overflow
            Expanded(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: selectedChat != null
                    ? Column(
                  children: [
                    chatBubble(
                      text: selectedChat!["question"],
                      isUser: true,
                      time: selectedChat!["timeAsked"],
                    ),
                    if (isTyping) loadingIndicator(),
                    if (selectedChat!["answer"].isNotEmpty) ...[
                      chatBubble(
                        text: selectedChat!["answer"],
                        isUser: false,
                        time: selectedChat!["timeAnswered"],
                      ),
                      optionsWidget(),
                    ],
                  ],
                )
                    : ListView.builder(
                  shrinkWrap: true, // Important to prevent overflow
                  physics: NeverScrollableScrollPhysics(), // Controlled by parent scroll
                  itemCount: allQuestions.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => fetchAnswer(index),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white10,
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.question_answer, color: Colors.white70),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                allQuestions[index]["question"],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Input field (Always visible above keyboard)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Type your question...",
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}
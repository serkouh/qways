import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qways/constant/apiservice.dart';

/// Demo FontSizes and Remix icon placeholders
class FontSizes {
  static const double xl = 18;
  static const double xl2 = 22;
  static const double xl4 = 28;
  static const double lg = 16;
}

class Remix {
  static const IconData send_plane_2_line = Icons.send;
  static const IconData arrow_left_line = Icons.arrow_back_ios;
  static const IconData phone_line = Icons.phone;
  static const IconData more_fill = Icons.more_vert;
}

class AppColors {
  static const primaryWhite = Colors.white;
  static const primaryGray = Colors.grey;
  static const primaryGreen = Colors.green;
}

/// Demo spacing
class Spacing {
  static const double xxsmall = 4;
  static const double base = 12;
}

/// Demo paddings
class Paddings {
  static const double base = 12;
  static const double large = 16;
}

class Chat {
  final int id;
  final int user1Id;
  final int user2Id;
  final String name;
  final String image;
  final String roomUUID; // ✅ Added

  Chat({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.name,
    required this.image,
    required this.roomUUID, // ✅ Added
  });
}

class Message {
  final int id;
  final String content;
  final bool isme;

  Message({
    required this.id,
    required this.content,
    required this.isme,
  });

  factory Message.fromJson(Map<String, dynamic> json, String currentUserId) {
    int parsedId = int.tryParse(json["id"]?.toString() ?? "0") ?? 0;
    String message = json["message"] ?? "";
    bool isMe = json["user_id"]?.toString() == currentUserId;

    return Message(
      id: parsedId,
      content: message,
      isme: isMe,
    );
  }
}

/// MessageCard widget
class MessageCard extends StatelessWidget {
  final bool isMe;
  final bool isAfterMe;
  final String message;

  const MessageCard({
    super.key,
    required this.isMe,
    required this.isAfterMe,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: isAfterMe ? 2 : 8,
          bottom: 2,
          left: 8,
          right: 8,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryGreen : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class ConversationDetailScreen extends StatefulWidget {
  final Chat chat; // MUST contain roomUUID
  const ConversationDetailScreen({super.key, required this.chat});

  @override
  State<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  final inputController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool sending = false;
  bool isEmpty = true;
  bool loading = true;

  List<Message> messages = [];

  @override
  void initState() {
    super.initState();

    inputController.addListener(() {
      setState(() => isEmpty = inputController.text.trim().isEmpty);
    });

    loadMessages();
  }

  // -------------------------------------------------------
  // 1️⃣ LOAD CHAT MESSAGES
  // -------------------------------------------------------
  Future<void> loadMessages() async {
    setState(() => loading = true);

    try {
      final response = await ApiService.post(
        endpoint: "get_room_chat_messages",
        body: {"room_uuid": widget.chat.roomUUID},
        withAuth: true,
      );

      final decoded = jsonDecode(response.body);
      print(response.body);

      List msgs = decoded["data"]["messages"] ?? [];
      String currentUserId = decoded["data"]["messages"].isNotEmpty
          ? decoded["data"]["messages"][0]["user_id"].toString()
          : ""; // fallback

      messages = msgs
          .map((e) => Message.fromJson(e, currentUserId))
          .toList()
          .cast<Message>();
    } catch (e) {
      debugPrint("❌ loadMessages error: $e");
    }

    setState(() => loading = false);
    scrollToBottom();
  }

  // -------------------------------------------------------
  // 2️⃣ SEND MESSAGE
  // -------------------------------------------------------
  Future<void> sendMessage() async {
    String text = inputController.text.trim();
    if (text.isEmpty || sending) return;

    setState(() => sending = true);

    // Add UI instantly
    final newMsg = Message(
      id: messages.isEmpty ? 1 : messages.last.id + 1,
      content: text,
      isme: true,
    );

    setState(() {
      messages.add(newMsg);
      inputController.clear();
    });
    scrollToBottom();

    try {
      final response = await ApiService.post(
        endpoint: "send_room_chat_message",
        body: {
          "room_uuid": widget.chat.roomUUID,
          "message": text,
          "message_type": "text"
        },
        withAuth: true,
      );
      print(response.body);
      final decoded = jsonDecode(response.body);

      if (decoded["status"] != true) {
        debugPrint("⚠ Message not delivered");
      }
    } catch (e) {
      debugPrint("❌ sendMessage error: $e");
    }

    setState(() => sending = false);
  }

  // -------------------------------------------------------
  // SCROLL TO BOTTOM
  // -------------------------------------------------------
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    inputController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------
  // UI
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _appBar(),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: loadMessages,
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return MessageCard(
                            isMe: messages[index].isme,
                            isAfterMe: index > 0 &&
                                messages[index - 1].isme ==
                                    messages[index].isme,
                            message: messages[index].content,
                          );
                        },
                      ),
                    ),
            ),
            _inputBox(),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // APP BAR
  // -------------------------------------------------------
  Widget _appBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          CircleAvatar(
            backgroundImage: NetworkImage(widget.chat.image),
            radius: 20,
          ),
          const SizedBox(width: 10),
          Text(widget.chat.name,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // INPUT BOX
  // -------------------------------------------------------
  Widget _inputBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: inputController,
              decoration: InputDecoration(
                hintText: "Type your message…",
                filled: true,
                fillColor: Colors.grey.shade300,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: isEmpty || sending ? null : sendMessage,
            icon: const Icon(Icons.send),
            color: Colors.white,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                (isEmpty || sending) ? Colors.grey : Colors.green,
              ),
              shape: MaterialStateProperty.all(const CircleBorder()),
            ),
          )
        ],
      ),
    );
  }
}

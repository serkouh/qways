import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qways/constant/apiservice.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/pages/chatting/chat.dart';
import 'package:qways/theme/theme.dart';

class RoomsListScreen extends StatefulWidget {
  const RoomsListScreen({super.key});

  @override
  State<RoomsListScreen> createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen> {
  List roomsList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.post(
        endpoint: "get_my_joined_rooms",
        withAuth: true,
        body: {
          "include_private": 1,
          "limit": 20,
          "offset": 0,
        },
      );

      print("++++++++++++++++++++++++++++++++++");
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final rawRooms = data['data']; // ✅ data is already a List

        setState(() {
          if (rawRooms is List) {
            roomsList = rawRooms;
          } else {
            roomsList = [];
            print("⚠️ WARNING: 'data' is not a list. Got: $rawRooms");
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load rooms";
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: whiteColor,
        title: Text(
          getTranslation(context, 'Rooms') ?? "Rooms",
          style: bold20BlackText,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : roomsList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.meeting_room_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No live rooms available",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(fixPadding * 2),
                      itemCount: roomsList.length,
                      itemBuilder: (context, index) {
                        // inside itemBuilder
                        final room = roomsList[index];

// Map API fields
                        final String name =
                            (room['room_name'] ?? 'Unknown Room').toString();
                        final String avatar = (room['host_profile'] != null &&
                                room['host_profile'].isNotEmpty)
                            ? room['host_profile'].toString()
                            : "https://i.pravatar.cc/150?img=12"; // default avatar
                        final int participants = int.tryParse(
                                room['current_participants'].toString()) ??
                            0;

                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: fixPadding * 2),
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to demo chat
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ConversationDetailScreen(
                                    chat: Chat(
                                      id: 1,
                                      user1Id: 100,
                                      user2Id: 200,
                                      name: name,
                                      roomUUID: room['room_uuid'],
                                      image: avatar,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(fixPadding * 2),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage: NetworkImage(avatar),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: bold16BlackText,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "$participants participants",
                                          style: semibold14Grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, '/CreateRoom');
        },
        child: const Icon(Icons.add, color: whiteColor),
      ),
    );
  }
}

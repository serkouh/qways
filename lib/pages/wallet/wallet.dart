import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qways/constant/apiservice.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/pages/chatting/chat.dart';
import 'package:qways/theme/theme.dart';
import 'package:qways/services/quiz_service.dart';

class RoomsListScreen extends StatefulWidget {
  const RoomsListScreen({super.key});

  @override
  State<RoomsListScreen> createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Lists
  List publicRooms = [];
  List myRooms = [];

  // Loading States
  bool isLoadingPublic = true;
  bool isLoadingMyRooms = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchPublicRooms();
    fetchMyRooms();
  }

  // ----------------------------------------------------
  // FETCH METHODS
  // ----------------------------------------------------

  Future<void> fetchPublicRooms() async {
    setState(() => isLoadingPublic = true);
    try {
      final rooms = await QuizService.getAllLiveRooms();
      if (mounted) setState(() => publicRooms = rooms);
    } catch (e) {
      print("Error fetching public rooms: $e");
    } finally {
      if (mounted) setState(() => isLoadingPublic = false);
    }
  }

  Future<void> fetchMyRooms() async {
    setState(() => isLoadingMyRooms = true);
    try {
      final response = await ApiService.post(
        endpoint: "get_my_joined_rooms",
        withAuth: true,
        body: {"include_private": 1, "limit": 20, "offset": 0},
      );
      final data = ApiService.decodeResponse(response);
      if (data['data'] is List) {
        if (mounted) setState(() => myRooms = data['data']);
      }
    } catch (e) {
      print("Error fetching my rooms: $e");
    } finally {
      if (mounted) setState(() => isLoadingMyRooms = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: whiteColor,
        centerTitle: true,
        title: Text(
          getTranslation(context, 'Room Library') ?? "Bibliothèque",
          style: bold20BlackText,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: greyColor,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(text: "Exploré"), // Public
            Tab(text: "Mes Salles"), // Joined
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRoomList(publicRooms, isLoadingPublic, isPublic: true),
          _buildRoomList(myRooms, isLoadingMyRooms, isPublic: false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, '/CreateRoom').then((_) {
            fetchPublicRooms();
            fetchMyRooms();
          });
        },
        child: const Icon(Icons.add, color: whiteColor),
      ),
    );
  }

  Widget _buildRoomList(List rooms, bool loading, {required bool isPublic}) {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.meeting_room_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              isPublic
                  ? "Aucune salle publique"
                  : "Vous n'avez rejoint aucune salle",
              style: semibold16Grey,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (isPublic)
          await fetchPublicRooms();
        else
          await fetchMyRooms();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rooms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final room = rooms[index];
          return _buildRoomCard(room, isPublic);
        },
      ),
    );
  }

  Widget _buildRoomCard(dynamic room, bool isPublic) {
    final String name = room['room_name'] ?? "Unknown Room";
    final int participants =
        int.tryParse(room['current_participants']?.toString() ?? "0") ?? 0;
    final int maxP =
        int.tryParse(room['max_participants']?.toString() ?? "0") ?? 0;
    final bool isPrivate = (room['room_type'] == 'private');
    final String uuid = room['room_uuid'] ?? "";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          // Icon / Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              isPrivate ? Icons.lock : Icons.public,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: bold16BlackText),
                const SizedBox(height: 4),
                Text(
                  "$participants / $maxP participants",
                  style: semibold14Grey.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          // Actions
          if (isPublic)
            _buildJoinButton(uuid)
          else
            _buildEnterButton(room), // For "My Rooms" we enter directly
        ],
      ),
    );
  }

  Widget _buildJoinButton(String uuid) {
    return ElevatedButton(
      onPressed: () => _joinRoom(uuid),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Text("Rejoindre", style: TextStyle(color: whiteColor)),
    );
  }

  Widget _buildEnterButton(dynamic room) {
    final uuid = room['room_uuid'];

    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          '/joinGame',
          arguments: {
            "room_uuid": uuid,
            // Pass defaults, journey will check API if not present or handle empty
            "current_step":
                int.tryParse(room['current_step']?.toString() ?? "1"),
            "score": int.tryParse(room['score']?.toString() ?? "0"),
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green, // Different color for "Enter"
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Text("Entrer", style: TextStyle(color: whiteColor)),
    );
  }

  Future<void> _joinRoom(String uuid) async {
    // Basic Join Logic
    try {
      final res = await QuizService.joinRoom(uuid);
      if (res['error'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Rejoint avec succès! Checking My Rooms...")),
        );
        // Refresh Lists
        _tabController.animateTo(1); // Switch to My Rooms
        fetchMyRooms();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "Erreur")),
        );
      }
    } catch (e) {
      print("Join Error: $e");
    }
  }
}

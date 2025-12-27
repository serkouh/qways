import 'package:flutter/material.dart';
import 'package:qways/model/quiz_models.dart';
import 'package:qways/pages/quiz/play_quiz_page.dart';
import 'package:qways/services/quiz_service.dart';
import 'package:qways/theme/theme.dart';

class GamesListScreen extends StatefulWidget {
  const GamesListScreen({super.key});

  @override
  State<GamesListScreen> createState() => _GamesListScreenState();
}

class _GamesListScreenState extends State<GamesListScreen> {
  List<GeoQuiz> _quizzes = [];
  bool _isLoading = true;
  Map<String, dynamic>? _activeGame;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final quizzes = await QuizService.getActiveQuizzes();
      final activeGame = await QuizService.getCurrentGame();
      
      setState(() {
        _quizzes = quizzes;
        _activeGame = activeGame;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error loading data: $e");
    }
  }

  Future<void> _startQuiz(GeoQuiz quiz) async {
    // Demo Flow: Create Room -> Join -> Start -> Play
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final roomName = "${quiz.title} Room"; // Simple name
      
      // 1. Create Room
      final createRes = await QuizService.createRoom(
        quizId: quiz.id,
        roomName: roomName,
      );
      final roomUuid = createRes['data']['room_uuid'];
      
      // 2. Join Room (Host joins automatically? API says player joins explicitly usually, but creating might auto-join or return token? 
      // Test.js does explicit join. Let's do explicit join.)
      await QuizService.joinRoom(roomUuid);
      
      // 3. Start Quiz
      await QuizService.startQuiz(roomUuid);
      
      Navigator.pop(context); // Close loading
      
      // 4. Navigate to Play
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayQuizPage(roomUuid: roomUuid),
        ),
      ).then((_) => _loadData()); // Reload when coming back
      
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error starting quiz: $e")),
      );
    }
  }

  void _resumeGame() {
    if (_activeGame == null) return;
    
    final roomUuid = _activeGame!['room_uuid'];
    final currentStep = int.tryParse(_activeGame!['current_step'].toString()) ?? 1;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayQuizPage(
          roomUuid: roomUuid,
          initialStep: currentStep,
        ),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text("Geo Quizzes", style: bold18White),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(fixPadding * 2),
                children: [
                  // Resume Card
                  if (_activeGame != null)
                    _buildResumeCard(),
                    
                  if (_activeGame != null)
                    heightSpace,
                    
                  Text("Available Quizzes", style: bold16BlackText),
                  heightSpace,

                  if (_quizzes.isEmpty)
                    _buildEmptyState()
                  else
                    ..._quizzes.map((q) => _buildQuizCard(q)),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create CUSTOM quiz screen (existing logic)
           Navigator.pushNamed(context, '/CreateGame'); 
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_rounded, color: whiteColor),
        label: Text("Create Quiz", style: bold16White),
      ),
    );
  }

  Widget _buildResumeCard() {
    return InkWell(
      onTap: _resumeGame,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
             const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
             const SizedBox(width: 15),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text(
                     "Continue Playing",
                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                   ),
                   const SizedBox(height: 4),
                   Text(
                     "${_activeGame!['quiz_title']}",
                     style: const TextStyle(color: Colors.white70, fontSize: 14),
                   ),
                   Text(
                     "Step ${_activeGame!['current_step']}",
                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                   ),
                 ],
               ),
             ),
             const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(GeoQuiz quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: fixPadding * 1.5),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.public, color: Colors.orange),
        ),
        title: Text(quiz.title, style: bold16BlackText),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (quiz.locationCity.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 2),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      "${quiz.locationCity}, ${quiz.locationCountry}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              quiz.description.isNotEmpty ? quiz.description : "No description",
              style: semibold14Grey,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _startQuiz(quiz),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text("Start", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(fixPadding * 4),
        child: Column(
          children: [
            Icon(Icons.quiz_outlined,
                color: primaryColor.withOpacity(0.6), size: 80),
            heightSpace,
            Text(
              "No quizzes available",
              style: bold18BlackText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

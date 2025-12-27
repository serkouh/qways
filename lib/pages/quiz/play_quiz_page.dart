import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qways/model/quiz_models.dart';
import 'package:qways/services/quiz_service.dart';
import 'package:qways/theme/theme.dart';

class PlayQuizPage extends StatefulWidget {
  final String roomUuid;
  final int initialStep;

  const PlayQuizPage({
    super.key,
    required this.roomUuid,
    this.initialStep = 1,
  });

  @override
  State<PlayQuizPage> createState() => _PlayQuizPageState();
}

class _PlayQuizPageState extends State<PlayQuizPage> {
  List<Question> _questions = [];
  bool _isLoading = true;
  int _currentStep = 1;
  int _score = 0;
  
  // Penalty State
  bool _inPenalty = false;
  int _penaltySecondsRemaining = 0;
  Timer? _penaltyTimer;
  
  // Question Timer
  int _questionTimeRemaining = 0;
  Timer? _questionTimer;
  
  // UI State
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _loadQuestions();
  }

  @override
  void dispose() {
    _penaltyTimer?.cancel();
    _questionTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await QuizService.getQuestions(widget.roomUuid);
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
      _startQuestionTimer();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading questions: $e")),
      );
    }
  }

  Question? get _currentQuestion {
    try {
      return _questions.firstWhere((q) => q.stepNumber == _currentStep);
    } catch (_) {
      return null;
    }
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    final q = _currentQuestion;
    if (q == null) return;

    setState(() {
      _questionTimeRemaining = q.timeLimitSeconds;
    });

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_questionTimeRemaining > 0) {
        setState(() => _questionTimeRemaining--);
      } else {
        timer.cancel();
        // Handle time out if needed, for now just let it sit at 0
      }
    });
  }

  void _startPenaltyTimer() {
    _penaltyTimer?.cancel();
    _penaltyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_penaltySecondsRemaining > 0) {
        setState(() => _penaltySecondsRemaining--);
      } else {
        setState(() => _inPenalty = false);
        timer.cancel();
      }
    });
  }

  Future<void> _submitAnswer(int answerIndex) async {
    if (_submitting || _inPenalty || _currentQuestion == null) return;

    setState(() => _submitting = true);

    try {
      final q = _currentQuestion!;
      
      final result = await QuizService.submitAnswer(
        roomUuid: widget.roomUuid,
        stepNumber: q.stepNumber,
        selectedAnswer: answerIndex,
        lat: q.latitude, // Using question loc as user loc for now
        lng: q.longitude,
        timeTaken: q.timeLimitSeconds - _questionTimeRemaining,
      );

      // Always update score and step if provided
      if (result.currentStep > 0 && result.currentStep != _currentStep) {
         setState(() {
           _currentStep = result.currentStep;
           _score = result.totalScore;
         });
         // If we advanced, restart question timer for the new question
         if (_currentQuestion != null) {
            _startQuestionTimer();
         }
      }

      if (result.inPenalty) {
        // WRONG ANSWER - PENALTY
        setState(() {
          _inPenalty = true;
          _penaltySecondsRemaining = result.penaltyRemainingSeconds > 0 
              ? result.penaltyRemainingSeconds 
              : result.timePenaltySeconds;
          _submitting = false;
        });
        _startPenaltyTimer();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Wrong Answer! Penalty: ${result.timePenaltySeconds}s"),
            backgroundColor: Colors.red,
          ),
        );
      } else if (result.isCorrect) {
        // CORRECT ANSWER
        setState(() {
          _score = result.totalScore; // Ensure score is synced
          _submitting = false;
        });
        
        // Step was already updated above if changed
        
        if (_currentQuestion != null) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Correct! Next Question..."),
                backgroundColor: Colors.green,
                duration: Duration(milliseconds: 1000),
              ),
            );
        } else {
           // Quiz Finished
           _showFinishedDialog();
        }
      } else {
          // Fallback if neither strictly correct nor penalty (e.g. correct but last question?)
           setState(() => _submitting = false);
      }
    } catch (e) {
       setState(() => _submitting = false);
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Quiz Completed! 🎉"),
        content: Text("You finished with a score of $_score."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: const Text("Awesome"),
          )
        ],
      ),
    );
  }

  Color _getTimerColor() {
    if (_questionTimeRemaining < 5) return Colors.red;
    if (_questionTimeRemaining < 10) return Colors.orange;
    return primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = _currentQuestion;
    if (q == null) {
       // Either finished or error
       if (_questions.isNotEmpty && _currentStep > _questions.last.stepNumber) {
           WidgetsBinding.instance.addPostFrameCallback((_) => _showFinishedDialog());
           return const Scaffold(body: SizedBox());
       }
       return Scaffold(
         appBar: AppBar(title: const Text("Error")),
         body: const Center(child: Text("Question not found")),
       );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Step $_currentStep"),
        centerTitle: true,
        backgroundColor: whiteColor,
        foregroundColor: blackColor,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: primaryColor, size: 20),
                const SizedBox(width: 4),
                Text("$_score", style: bold16Primary),
              ],
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timer
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _questionTimeRemaining / q.timeLimitSeconds,
                        strokeWidth: 5,
                        color: _getTimerColor(),
                        backgroundColor: Colors.grey.shade200,
                      ),
                      Text("$_questionTimeRemaining", style: bold18BlackText),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Question
                Text(
                  q.question,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Points: ${q.points}",
                  style: semibold14Grey,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),

                // Options
                _buildOptionBtn(1, q.option1),
                const SizedBox(height: 15),
                _buildOptionBtn(2, q.option2),
                const SizedBox(height: 15),
                _buildOptionBtn(3, q.option3),
                
                const Spacer(),
              ],
            ),
          ),

          // Penalty Overlay
          if (_inPenalty)
            Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_clock, color: Colors.white, size: 60),
                    const SizedBox(height: 20),
                    const Text(
                      "PENALTY ACTIVE",
                      style: TextStyle(color: Colors.redAccent, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Wait $_penaltySecondsRemaining seconds...",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            
          // Loading Overlay
          if (_submitting)
             Container(
               color: Colors.black.withOpacity(0.3),
               child: const Center(child: CircularProgressIndicator()),
             )
        ],
      ),
    );
  }

  Widget _buildOptionBtn(int index, String text) {
    return ElevatedButton(
      onPressed: (_inPenalty || _submitting) ? null : () => _submitAnswer(index),
      style: ElevatedButton.styleFrom(
        foregroundColor: blackColor,
        backgroundColor: whiteColor,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Text("$index", style: bold16Primary),
          ),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:qways/theme/theme.dart';

class CreateGeoQuizPage extends StatefulWidget {
  const CreateGeoQuizPage({super.key});

  @override
  State<CreateGeoQuizPage> createState() => _CreateGeoQuizPageState();
}

class _CreateGeoQuizPageState extends State<CreateGeoQuizPage> {
  final _questionController = TextEditingController();
  final List<TextEditingController> _answerControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int? _correctAnswerIndex;
  LatLng? _selectedLocation;

  List<Map<String, dynamic>> quizData = [];

  late GoogleMapController _mapController;
  LatLng initialPos = const LatLng(48.8566, 2.3522); // Paris default

  void _addQuestion() {
    if (_selectedLocation == null ||
        _questionController.text.isEmpty ||
        _answerControllers.any((a) => a.text.isEmpty) ||
        _correctAnswerIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and choose a location"),
        ),
      );
      return;
    }

    setState(() {
      quizData.add({
        "question": _questionController.text,
        "answers": _answerControllers.map((c) => c.text).toList(),
        "correct": _correctAnswerIndex,
        "location": _selectedLocation,
      });

      // Reset
      _questionController.clear();
      for (var c in _answerControllers) c.clear();
      _correctAnswerIndex = null;
      _selectedLocation = null;
    });
  }

  void _deleteQuestion(int index) {
    setState(() => quizData.removeAt(index));
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var c in _answerControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        title: const Text("🗺️ Create Geo Quiz (Demo)"),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: _addQuestion,
        icon: const Icon(Icons.add),
        label: const Text("Add Question"),
      ),
      body: Column(
        children: [
          // 🗺️ MAP SELECTOR
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: initialPos, zoom: 4),
                  onMapCreated: (controller) => _mapController = controller,
                  onTap: (pos) => setState(() => _selectedLocation = pos),
                  markers: _selectedLocation != null
                      ? {
                          Marker(
                            markerId: const MarkerId("selected"),
                            position: _selectedLocation!,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueOrange),
                          )
                        }
                      : {},
                ),

                // Gradient overlay for readability
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.15),
                            Colors.transparent
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),

                // Location label
                if (_selectedLocation != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: whiteColor.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: Text(
                        "📍 ${_selectedLocation!.latitude.toStringAsFixed(4)}, "
                        "${_selectedLocation!.longitude.toStringAsFixed(4)}",
                        style: semibold14Grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 🧠 QUESTION BUILDER
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    Text("🧩 Question Details", style: bold16BlackText),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Enter your question...",
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("💡 Answers", style: bold16BlackText),
                    const SizedBox(height: 8),
                    ...List.generate(_answerControllers.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _answerControllers[i],
                                  decoration: InputDecoration(
                                    hintText: "Answer ${i + 1}",
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(12),
                                  ),
                                ),
                              ),
                              Radio<int>(
                                value: i,
                                groupValue: _correctAnswerIndex,
                                onChanged: (val) =>
                                    setState(() => _correctAnswerIndex = val),
                                activeColor: primaryColor,
                              ),
                              const Text("✔️"),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 25),
                    Text("🗒️ Created Questions", style: bold16BlackText),
                    const SizedBox(height: 10),

                    // 📋 QUESTIONS LIST
                    if (quizData.isNotEmpty)
                      AnimatedList(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        initialItemCount: quizData.length,
                        itemBuilder: (context, index, animation) {
                          final q = quizData[index];
                          final loc = q["location"] as LatLng;
                          return SizeTransition(
                            sizeFactor: animation,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 2,
                              child: ListTile(
                                leading: const Icon(Icons.location_on,
                                    color: Colors.orange),
                                title: Text(q["question"],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  "(${loc.latitude.toStringAsFixed(3)}, "
                                  "${loc.longitude.toStringAsFixed(3)})",
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteQuestion(index),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    if (quizData.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.map_outlined,
                                  color: Colors.grey.shade400, size: 40),
                              const SizedBox(height: 8),
                              Text(
                                "No questions yet.\nTap on the map and add one!",
                                textAlign: TextAlign.center,
                                style: semibold14Grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

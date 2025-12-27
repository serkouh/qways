import 'dart:convert';

import 'package:qways/constant/apiservice.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:qways/constant/apiservice.dart';
import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final TextEditingController codeCtrl = TextEditingController();

  Future<void> handleJoinRoom(String fullCode) async {
    try {
      if (!fullCode.contains(".")) {
        showError("Invalid code format.\nExpected: ROOMID.QUIZID");
        return;
      }

      final parts = fullCode.split(".");
      if (parts.length != 2) {
        showError("Invalid code format.\nExample: ABC123.5");
        return;
      }

      final roomUuid = parts[0];
      final quizId = parts[1];

      print("🔍 Extracted:");
      print("• Room UUID = $roomUuid");
      print("• Geo Quiz ID = $quizId");

      // ------------------------------------------------
      // JOIN ROOM API
      // ------------------------------------------------
      final joinResponse = await ApiService.post(
        endpoint: "join_geo_quiz_room",
        body: {"room_uuid": roomUuid},
        withAuth: true,
      );

      print("🔽 JoinRoom response: ${joinResponse.body}");

      if (joinResponse.statusCode != 200 ||
          joinResponse.body.isEmpty ||
          joinResponse.body == "{}") {
        showError(getApiMessage(joinResponse.body));
        return;
      }

      final joinData = jsonDecode(joinResponse.body);

      if (joinData["data"] == null) {
        showError(getApiMessage(joinResponse.body));
        return;
      }

      showSuccess("Successfully joined room!");

      await Future.delayed(const Duration(milliseconds: 700));

      Navigator.pushNamed(
        context,
        '/joinGame',
        arguments: {
          "room_uuid": roomUuid,
          "quiz_id": quizId,
        },
      );
    } catch (e) {
      showError("Failed to join room. Try again.");
    }
  }

  // ---------------------------------------------------------
  // POPUP FEEDBACK
  // ---------------------------------------------------------
  void showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        title: const Text("Error", style: TextStyle(color: Colors.red)),
        content: Text(msg, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            child: const Text("OK", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void showSuccess(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.green.shade50,
        title: const Text("Success", style: TextStyle(color: Colors.green)),
        content: Text(msg, style: const TextStyle(fontSize: 16)),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context); // close dialog
    });
  }

  // ---------------------------------------------------------
  // UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: whiteColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(fixPadding * 2),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              scanTitle(context),
              heightBox(3.0),
              contentText(context),
              heightSpace,

              // -------------------------------------------------
              // QR SCAN BUTTON (opens scanner)
              // -------------------------------------------------
              InkWell(
                onTap: () async {
                  final scanned =
                      await Navigator.pushNamed(context, '/qrScanner');

                  if (scanned != null) {
                    codeCtrl.text = scanned.toString();
                    handleJoinRoom(scanned.toString());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.15),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.qr_code_scanner,
                          size: 80, color: Colors.white),
                      SizedBox(height: 10),
                      Text("Scan QR Code",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              heightSpace,
              heightSpace,

              // -------------------------------------------------
              // ENTER CODE MANUALLY
              // -------------------------------------------------
              Container(
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                  boxShadow: [
                    BoxShadow(
                        color: blackColor.withOpacity(0.1), blurRadius: 5),
                  ],
                ),
                child: TextField(
                  controller: codeCtrl,
                  cursorColor: primaryColor,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: InputBorder.none,
                    hintText: "Enter code manually (e.g., ROOM123.5)",
                    hintStyle: bold16Grey,
                  ),
                ),
              ),

              heightSpace,

              // -------------------------------------------------
              // BEAUTIFUL JOIN BUTTON
              // -------------------------------------------------
              InkWell(
                onTap: () {
                  if (codeCtrl.text.trim().isEmpty) {
                    showError("Please enter a code first.");
                    return;
                  }
                  handleJoinRoom(codeCtrl.text.trim());
                },
                child: Container(
                  height: 55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Join Game",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              heightSpace,
            ],
          ),
        ),
      ),
    );
  }

  scanTitle(context) => Text(
        getTranslation(context, 'scan.scan_unlock'),
        style: bold22BlackText,
        textAlign: TextAlign.center,
      );

  contentText(context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: fixPadding * 3.0),
        child: Text(
          getTranslation(context, 'scan.scan_code_text'),
          style: bold16Grey,
          textAlign: TextAlign.center,
        ),
      );
}

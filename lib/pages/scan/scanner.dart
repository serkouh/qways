import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanned = false;

  @override
  void reassemble() {
    super.reassemble();
    // Fix camera issues on hot reload
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;

    ctrl.scannedDataStream.listen((scanData) {
      if (isScanned) return; // Prevent double pop
      isScanned = true;

      controller?.pauseCamera();
      Navigator.pop(context, scanData.code);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.white,
              borderWidth: 10,
              borderLength: 30,
              borderRadius: 15,
              cutOutSize: MediaQuery.of(context).size.width * 0.7,
            ),
          ),

          // back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  controller?.dispose();
                  Navigator.pop(context);
                },
              ),
            ),
          ),

          // scanning label
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Scan the QR Code",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

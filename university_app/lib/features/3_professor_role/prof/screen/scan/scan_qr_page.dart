import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ✅ Import the unified service
import 'package:university_app/core/services/professor_service.dart';

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  // Scanner controller configured for QR codes
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode], // Optimized for QR
  );

  final ProfessorService _professorService = ProfessorService();
  bool _isProcessing = false;

  // Variable to store session data to pass later to the print page
  Map<String, dynamic>? sessionArgs;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    // Check if session data exists
    if (sessionArgs == null || sessionArgs!['groupeId'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur: Données de séance manquantes"))
      );
      return;
    }

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      // ✅ Call service to verify student (CNE) in the specific group
      bool isValid = await _professorService.verifyCneAndGroup(
        cne: rawValue,
        groupId: sessionArgs!['groupeId'],
      );

      if (!mounted) return;

      // Show result dialog
      await _showResultDialog(isValid, rawValue);

    } catch (e) {
      debugPrint("Scan Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showResultDialog(bool isValid, String cne) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must click button to close
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isValid ? Colors.green.shade50 : Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isValid ? LucideIcons.checkCircle : LucideIcons.xCircle,
                    size: 50,
                    color: isValid ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isValid ? "Étudiant Vérifié" : "Étudiant Non Inscrit",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  isValid
                      ? "L'étudiant avec le CNE $cne fait bien partie de ce groupe."
                      : "L'étudiant avec le CNE $cne n'appartient pas à ce groupe.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(), // Close dialog to scan next
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isValid ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Scanner le suivant", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Retrieve arguments passed from previous screen
    sessionArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner QR Code"),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
        actions: [
          // Flash Button
          ValueListenableBuilder(
            valueListenable: _cameraController,
            builder: (context, state, child) {
              return IconButton(
                icon: Icon(state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off),
                onPressed: () => _cameraController.toggleTorch(),
              );
            },
          ),

          // ✅✅✅ "Terminer" Button ✅✅✅
          // Navigates directly to Manual List / Print page
          TextButton.icon(
            onPressed: () {
              if (sessionArgs != null) {
                Navigator.pushNamed(context, '/manualList', arguments: sessionArgs);
              }
            },
            icon: const Icon(Icons.print, color: Colors.white),
            label: const Text("Terminer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
          ),

          // Dark Overlay with Cutout
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.srcOut),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut
                  ),
                ),
                // Transparent Square Cutout
                Center(
                  child: Container(
                    width: 280,
                    height: 280, // Square for QR
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)
                    ),
                  ),
                ),
              ],
            ),
          ),

          // White Border Frame
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(20)
              ),
            ),
          ),

          // Helper Text
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                    "Placez le code QR dans le cadre",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)
                ),
                SizedBox(height: 8),
                Text(
                    "La détection est automatique",
                    style: TextStyle(color: Colors.white70, fontSize: 12)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
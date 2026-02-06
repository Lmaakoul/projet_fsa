import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ✅ استيراد السيرفس الموحد
import 'package:university_app/core/services/professor_service.dart';

class ScanBarcodePage extends StatefulWidget {
  const ScanBarcodePage({super.key});

  @override
  State<ScanBarcodePage> createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> {
  // إعداد الماسح الضوئي
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.all],
  );

  final ProfessorService _professorService = ProfessorService();
  bool _isProcessing = false;

  // متغير لتخزين كافة البيانات لتمريرها لاحقاً لصفحة الطباعة
  Map<String, dynamic>? sessionArgs;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    if (sessionArgs == null || sessionArgs!['groupeId'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur: Données de séance manquantes")));
      return;
    }

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      // ✅ استدعاء السيرفر للتحقق من الطالب (CNE)
      bool isValid = await _professorService.verifyCneAndGroup(
        cne: rawValue,
        groupId: sessionArgs!['groupeId'],
      );

      if (!mounted) return;

      // عرض النتيجة
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
      barrierDismissible: false,
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
                  isValid ? "Vérifié" : "Non Inscrit",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  isValid
                      ? "Étudiant ($cne) validé pour cette séance."
                      : "L'étudiant ($cne) n'appartient pas à ce groupe.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isValid ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Continuer", style: TextStyle(fontSize: 16)),
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
    // ✅ استقبال البيانات الممررة عبر Navigator
    sessionArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Code-Barres'),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
        actions: [
          // زر الفلاش
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, state, child) {
              return IconButton(
                icon: Icon(state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off),
                onPressed: () => controller.toggleTorch(),
              );
            },
          ),

          // ✅✅✅ زر "إنهاء وطباعة" الجديد ✅✅✅
          TextButton.icon(
            onPressed: () {
              if (sessionArgs != null) {
                // الانتقال لصفحة القائمة للطباعة
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
          MobileScanner(controller: controller, onDetect: _onDetect),

          // طبقة التعتيم
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.srcOut),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.black, backgroundBlendMode: BlendMode.dstOut),
                ),
                // المنطقة الشفافة (مستطيل عريض للباركود)
                Center(
                  child: Container(
                    width: 320,
                    height: 150,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),

          // الإطار الأحمر
          Center(
            child: Container(
              width: 320,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Positioned(
            bottom: 50, left: 0, right: 0,
            child: const Text(
              "Alignez le code-barres dans le cadre rouge",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, backgroundColor: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
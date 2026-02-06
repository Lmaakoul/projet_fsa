import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:university_app/core/services/auth_service.dart';

class CodeQRPage extends StatefulWidget {
  final int? etudiantId;
  final bool showQr; // ✅ متغير جديد: true = QR, false = Barcode

  const CodeQRPage({
    super.key,
    this.etudiantId,
    this.showQr = true, // القيمة الافتراضية
  });

  @override
  State<CodeQRPage> createState() => _CodeQRPageState();
}

class _CodeQRPageState extends State<CodeQRPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _cne;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (widget.etudiantId != null) {
        setState(() {
          // محاكاة CNE (استبدلها بالـ Service الحقيقي لاحقاً)
          _cne = "D13${widget.etudiantId}99";
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "ID introuvable";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Erreur";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.showQr ? "Mon QR Code" : "Mon Code-Barres"),
        backgroundColor: const Color(0xFF190B60),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ شرط العرض: إما QR أو Barcode
              if (widget.showQr)
                QrImageView(
                  data: _cne ?? "Unknown",
                  version: QrVersions.auto,
                  size: 250.0,
                  foregroundColor: const Color(0xFF190B60),
                )
              else
                BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: _cne ?? "Unknown",
                  width: double.infinity,
                  height: 120,
                  color: const Color(0xFF190B60),
                  drawText: true,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4),
                ),

              const SizedBox(height: 30),

              // نص CNE أسفل الكود
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text("Identifiant (CNE)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 5),
                    Text(
                      _cne ?? "---",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF190B60)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
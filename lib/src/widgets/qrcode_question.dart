import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

/// QR / Barcode scanner question.
///
/// JSON usage:
/// ```json
/// { "type": "qrcode", "name": "myQr", "title": "امسح الباركود" }
/// ```
class QrCodeQuestion extends StatefulWidget {
  final QuestionModel question;
  final String? currentValue;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const QrCodeQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentValue,
    this.enabled = true,
  });

  @override
  State<QrCodeQuestion> createState() => _QrCodeQuestionState();
}

class _QrCodeQuestionState extends State<QrCodeQuestion> {
  String? _scanned;

  @override
  void initState() {
    super.initState();
    _scanned = widget.currentValue;
  }

  Future<void> _openScanner() async {
    if (!widget.enabled) return;
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _ScannerPage()),
    );
    if (result != null && mounted) {
      setState(() => _scanned = result);
      widget.onChanged(result);
    }
  }

  void _clear() {
    setState(() => _scanned = null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final hasValue = _scanned != null && _scanned!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Result display ─────────────────────────────────────────────────
        if (hasValue)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.08),
              borderRadius: theme.inputBorderRadius,
              border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.qr_code_2, color: theme.primaryColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _scanned!,
                    style: theme.inputTextStyle.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                if (widget.enabled)
                  GestureDetector(
                    onTap: _clear,
                    child: Icon(Icons.close, size: 18, color: theme.hintColor),
                  ),
              ],
            ),
          ),

        // ── Scan button ────────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.enabled ? _openScanner : null,
            icon: Icon(hasValue ? Icons.qr_code_scanner : Icons.qr_code_2),
            label: Text(hasValue ? 'Scan again' : 'Scan QR / Barcode'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.primaryColor,
              side: BorderSide(color: theme.primaryColor),
              shape: RoundedRectangleBorder(borderRadius: theme.buttonBorderRadius),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Full-screen scanner page ─────────────────────────────────────────────────

class _ScannerPage extends StatefulWidget {
  const _ScannerPage();

  @override
  State<_ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<_ScannerPage> {
  final MobileScannerController _ctrl = MobileScannerController();
  bool _detected = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_detected) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value != null && value.isNotEmpty) {
      _detected = true;
      Navigator.pop(context, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR / Barcode'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _ctrl.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _ctrl.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _ctrl, onDetect: _onDetect),

          // Overlay frame
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Hint text
          Positioned(
            bottom: 48,
            left: 0, right: 0,
            child: Text(
              'Point at a QR code or barcode',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

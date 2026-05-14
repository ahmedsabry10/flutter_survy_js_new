import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

/// Renders a SurveyJS `signaturepad` question.
/// Pure Flutter — no external package needed.
class SignaturePadQuestion extends StatefulWidget {
  final QuestionModel question;
  final dynamic currentValue;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const SignaturePadQuestion({
    super.key,
    required this.question,
    required this.onChanged,
    this.currentValue,
    this.enabled = true,
  });

  @override
  State<SignaturePadQuestion> createState() => _SignaturePadQuestionState();
}

class _SignaturePadQuestionState extends State<SignaturePadQuestion> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _hasSignature = false;

  // FIX: Use Listener (pointer events) instead of GestureDetector (gesture arena).
  // GestureDetector competes with the parent PageView/ScrollView and loses,
  // so pan events never reach the signature pad.
  // Listener fires at pointer level — before gesture disambiguation — so it
  // always receives events regardless of parent scroll widgets.

  void _onPointerDown(PointerDownEvent e) {
    if (!widget.enabled) return;
    setState(() {
      _currentStroke = [e.localPosition];
      _hasSignature = true;
    });
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (!widget.enabled) return;
    setState(() => _currentStroke.add(e.localPosition));
  }

  void _onPointerUp(PointerUpEvent e) {
    if (!widget.enabled || _currentStroke.isEmpty) return;
    setState(() {
      _strokes.add(List.from(_currentStroke));
      _currentStroke = [];
    });
    widget.onChanged('signature_${_strokes.length}_strokes');
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
      _hasSignature = false;
    });
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SurveyTheme.of(context);
    final padWidth = widget.question.signatureWidth?.toDouble() ?? double.infinity;
    final padHeight = widget.question.signatureHeight?.toDouble() ?? 180;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Signature canvas
        ClipRRect(
          borderRadius: theme.inputBorderRadius,
          child: Container(
            height: padHeight,
            width: padWidth == double.infinity ? double.infinity : padWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: theme.inputBorderRadius,
              border: Border.all(
                color: _hasSignature ? theme.primaryColor : theme.borderColor,
                width: _hasSignature ? 1.5 : 1,
              ),
            ),
            child: Listener(
              // FIX: Listener instead of GestureDetector
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              // HitTestBehavior.opaque ensures we get ALL pointer events
              // even when the canvas is "empty"
              behavior: HitTestBehavior.opaque,
              child: CustomPaint(
                painter: _SignaturePainter(
                  strokes: _strokes,
                  currentStroke: _currentStroke,
                  penColor: Colors.black87,
                ),
                child: _hasSignature
                    ? null
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.draw_outlined,
                                size: 28, color: theme.hintColor),
                            const SizedBox(height: 6),
                            Text(
                              'Sign here',
                              style: TextStyle(
                                  color: theme.hintColor, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),

        // Controls row
        const SizedBox(height: 8),
        Row(
          children: [
            if (widget.enabled && _hasSignature)
              OutlinedButton.icon(
                onPressed: _clear,
                icon: Icon(Icons.clear, size: 16, color: theme.errorColor),
                label: Text('Clear',
                    style: TextStyle(color: theme.errorColor, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side:
                      BorderSide(color: theme.errorColor.withOpacity(0.5)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: theme.buttonBorderRadius),
                ),
              ),
            if (_hasSignature) ...[
              const SizedBox(width: 10),
              Icon(Icons.check_circle_outline,
                  size: 16, color: theme.primaryColor),
              const SizedBox(width: 4),
              Text('Signed',
                  style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ],
    );
  }
}

// ─── Painter ──────────────────────────────────────────────────────────────────

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color penColor;

  const _SignaturePainter({
    required this.strokes,
    required this.currentStroke,
    required this.penColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = penColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    void drawStroke(List<Offset> pts) {
      if (pts.isEmpty) return;
      if (pts.length == 1) {
        // Single dot
        canvas.drawCircle(pts.first, 1.5, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        return;
      }
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (int i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    for (final stroke in strokes) drawStroke(stroke);
    if (currentStroke.isNotEmpty) drawStroke(currentStroke);
  }

  @override
  bool shouldRepaint(_SignaturePainter old) =>
      old.strokes != strokes || old.currentStroke != currentStroke;
}

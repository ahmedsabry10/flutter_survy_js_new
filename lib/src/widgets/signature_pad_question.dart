import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

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
    final padHeight =
        widget.question.signatureHeight?.toDouble() ?? 180;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Canvas
        ClipRRect(
          borderRadius: theme.inputBorderRadius,
          child: Container(
            height: padHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: theme.inputBorderRadius,
              border: Border.all(
                color: _hasSignature
                    ? theme.primaryColor
                    : theme.borderColor,
                width: _hasSignature ? 1.5 : 1,
              ),
            ),
            // Listener with HitTestBehavior.opaque:
            // - fires at raw pointer level, BEFORE gesture arena
            // - opaque means it catches events even on empty/transparent areas
            // - never competes with or loses to parent ScrollView
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              child: CustomPaint(
                painter: _SignaturePainter(
                  strokes: _strokes,
                  currentStroke: _currentStroke,
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
                            Text('Sign here',
                                style: TextStyle(
                                    color: theme.hintColor,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),

        // Controls
        const SizedBox(height: 8),
        Row(
          children: [
            if (widget.enabled && _hasSignature)
              OutlinedButton.icon(
                onPressed: _clear,
                icon: Icon(Icons.clear, size: 16, color: theme.errorColor),
                label: Text('Clear',
                    style:
                        TextStyle(color: theme.errorColor, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: theme.errorColor.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
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

  const _SignaturePainter({
    required this.strokes,
    required this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    void drawStroke(List<Offset> pts) {
      if (pts.isEmpty) return;
      if (pts.length == 1) {
        canvas.drawCircle(
            pts.first, 1.5, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        return;
      }
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (int i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    for (final s in strokes) drawStroke(s);
    if (currentStroke.isNotEmpty) drawStroke(currentStroke);
  }

  @override
  bool shouldRepaint(_SignaturePainter old) =>
      old.strokes != strokes || old.currentStroke != currentStroke;
}

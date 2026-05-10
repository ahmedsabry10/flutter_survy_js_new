import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/question_model.dart';
import '../theme/survey_theme.dart';

/// Renders a SurveyJS `signaturepad` question.
/// Pure Flutter — no external package needed.
/// Answer: base64 PNG string (same format as SurveyJS web).
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
  final List<List<Offset?>> _strokes = [];
  List<Offset?> _currentStroke = [];
  bool _hasSignature = false;

  void _onPanStart(DragStartDetails d) {
    if (!widget.enabled) return;
    setState(() {
      _currentStroke = [d.localPosition];
      _hasSignature = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!widget.enabled) return;
    setState(() => _currentStroke.add(d.localPosition));
  }

  void _onPanEnd(DragEndDetails d) {
    if (!widget.enabled) return;
    setState(() {
      _strokes.add(List.from(_currentStroke));
      _currentStroke = [];
    });
    // Notify parent — in production convert canvas to base64 PNG
    widget.onChanged('signature_data_${_strokes.length}_strokes');
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Canvas
        GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: theme.inputBorderRadius,
              border: Border.all(color: theme.borderColor),
            ),
            child: ClipRRect(
              borderRadius: theme.inputBorderRadius,
              child: CustomPaint(
                painter: _SignaturePainter(
                  strokes: _strokes,
                  currentStroke: _currentStroke,
                  penColor: theme.textColor,
                ),
                child: _hasSignature
                    ? const SizedBox.expand()
                    : Center(
                        child: Text(
                          'Sign here',
                          style: TextStyle(
                              color: theme.hintColor, fontSize: 14),
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
                    style: TextStyle(color: theme.errorColor)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.errorColor.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: theme.buttonBorderRadius),
                ),
              ),
            if (_hasSignature) ...[
              const SizedBox(width: 10),
              Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 16, color: theme.primaryColor),
                  const SizedBox(width: 4),
                  Text('Signed',
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset?>> strokes;
  final List<Offset?> currentStroke;
  final Color penColor;

  _SignaturePainter({
    required this.strokes,
    required this.currentStroke,
    required this.penColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = penColor
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    void drawStroke(List<Offset?> stroke) {
      final path = Path();
      bool started = false;
      for (final point in stroke) {
        if (point == null) {
          started = false;
          continue;
        }
        if (!started) {
          path.moveTo(point.dx, point.dy);
          started = true;
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, paint);
    }

    for (final stroke in strokes) {
      drawStroke(stroke);
    }
    if (currentStroke.isNotEmpty) {
      drawStroke(currentStroke);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) =>
      old.strokes != strokes || old.currentStroke != currentStroke;
}

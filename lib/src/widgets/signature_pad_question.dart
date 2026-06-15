import 'dart:convert';

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
  // Strokes are stored in normalized [0..1] coordinates relative to the
  // canvas size, so the signature renders correctly at any canvas width/height.
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _hasSignature = false;
  Size _canvasSize = Size.zero;

  // Convert a raw local pointer position into normalized [0..1] coordinates.
  Offset _normalize(Offset local) {
    final w = _canvasSize.width;
    final h = _canvasSize.height;
    if (w <= 0 || h <= 0) return Offset.zero;
    return Offset(
      (local.dx / w).clamp(0.0, 1.0),
      (local.dy / h).clamp(0.0, 1.0),
    );
  }

  @override
  void initState() {
    super.initState();
    _restore();
  }

  // Serialize strokes to a JSON string of [[ [dx, dy], ... ], ...].
  String _encode() {
    return jsonEncode(
      _strokes
          .map((stroke) => stroke.map((p) => [p.dx, p.dy]).toList())
          .toList(),
    );
  }

  // Rebuild strokes from a previously saved value.
  // Safely ignores empty values and the legacy 'signature_N_strokes' format.
  void _restore() {
    final value = widget.currentValue;
    if (value is! String || value.isEmpty) return;
    if (value.startsWith('signature_')) return; // legacy placeholder, no data
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List) return;
      for (final stroke in decoded) {
        if (stroke is! List) continue;
        final pts = <Offset>[];
        for (final p in stroke) {
          if (p is List && p.length >= 2 && p[0] is num && p[1] is num) {
            pts.add(Offset((p[0] as num).toDouble(), (p[1] as num).toDouble()));
          }
        }
        if (pts.isNotEmpty) _strokes.add(pts);
      }
      if (_strokes.isNotEmpty) _hasSignature = true;
    } catch (_) {
      // Malformed value — leave the canvas empty.
    }
  }

  void _onPointerDown(PointerDownEvent e) {
    if (!widget.enabled) return;
    setState(() {
      _currentStroke = [_normalize(e.localPosition)];
      _hasSignature = true;
    });
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (!widget.enabled) return;
    setState(() => _currentStroke.add(_normalize(e.localPosition)));
  }

  void _onPointerUp(PointerUpEvent e) {
    if (!widget.enabled || _currentStroke.isEmpty) return;
    setState(() {
      _strokes.add(List.from(_currentStroke));
      _currentStroke = [];
    });
    widget.onChanged(_encode());
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                _canvasSize = Size(constraints.maxWidth, padHeight);
                return Listener(
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
                );
              },
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

    // Strokes are stored normalized [0..1]; scale back to the actual canvas.
    Offset toPixel(Offset p) => Offset(p.dx * size.width, p.dy * size.height);

    void drawStroke(List<Offset> pts) {
      if (pts.isEmpty) return;
      if (pts.length == 1) {
        canvas.drawCircle(
            toPixel(pts.first), 1.5, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        return;
      }
      final first = toPixel(pts.first);
      final path = Path()..moveTo(first.dx, first.dy);
      for (int i = 1; i < pts.length; i++) {
        final pt = toPixel(pts[i]);
        path.lineTo(pt.dx, pt.dy);
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

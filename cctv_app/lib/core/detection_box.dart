import 'dart:ui';

class DetectionBox {
  final int classId;
  final double confidence;
  final Rect bbox;

  DetectionBox(this.classId, this.confidence, this.bbox);
}

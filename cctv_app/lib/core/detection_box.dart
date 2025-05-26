import 'dart:ui';

/// 객체 감지 결과를 나타내는 클래스
class DetectionBox {
  /// 감지된 객체의 클래스 ID (예: 사람, 자동차 등)
  final int classId;

  /// 감지 신뢰도 (0.0 ~ 1.0)
  final double confidence;

  /// 객체의 위치와 크기를 나타내는 사각형(Rect)
  final Rect bbox;

  /// DetectionBox 생성자
  /// [classId]: 객체 클래스 ID
  /// [confidence]: 신뢰도
  /// [bbox]: 바운딩 박스(Rect)
  DetectionBox(this.classId, this.confidence, this.bbox);
}

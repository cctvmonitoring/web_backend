import 'package:flutter/material.dart';
import '../core/detection_box.dart';

/// 감지된 객체들의 바운딩 박스를 이미지 위에 오버레이로 표시하는 위젯
class DetectionOverlay extends StatelessWidget {
  /// 감지된 객체들의 바운딩 박스 리스트
  final List<DetectionBox> boxes;
  /// 원본 이미지의 너비
  final double imageWidth;
  /// 원본 이미지의 높이
  final double imageHeight;
  /// 화면에 렌더링할 이미지의 너비
  final double renderWidth;
  /// 화면에 렌더링할 이미지의 높이
  final double renderHeight;

  /// 생성자
  const DetectionOverlay({
    super.key,
    required this.boxes,
    required this.imageWidth,
    required this.imageHeight,
    required this.renderWidth,
    required this.renderHeight,
  });

  @override
  Widget build(BuildContext context) {
    // 원본 이미지와 렌더링 이미지의 비율 계산
    final scaleX = renderWidth / imageWidth;
    final scaleY = renderHeight / imageHeight;

    // 각 감지 박스를 Stack의 Positioned 위젯으로 변환하여 오버레이
    return Stack(
      children: boxes.map((box) {
        final rect = box.bbox;
        return Positioned(
          left: rect.left * scaleX,
          top: rect.top * scaleY,
          width: rect.width * scaleX,
          height: rect.height * scaleY,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: Text(
              // 클래스 ID와 신뢰도(%) 표시
              '${box.classId} ${(box.confidence * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

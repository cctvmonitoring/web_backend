// import 'package:flutter/material.dart';
// import '../core/detection_box.dart';

// /// 감지된 객체들의 바운딩 박스를 이미지 위에 오버레이로 표시하는 위젯

// class DetectionOverlay extends StatelessWidget {
//   final List<DetectionBox> boxes;
//   final double imageWidth;
//   final double imageHeight;
//   final double renderWidth;
//   final double renderHeight;

//   const DetectionOverlay({
//     super.key,
//     required this.boxes,
//     required this.imageWidth,
//     required this.imageHeight,
//     required this.renderWidth,
//     required this.renderHeight,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final scaleX = renderWidth / imageWidth;
//     final scaleY = renderHeight / imageHeight;

//     return SizedBox( // ✅ 반드시 크기 지정
//       width: renderWidth,
//       height: renderHeight,
//       child: Stack(
//         children: boxes.map((box) {
//           final rect = box.bbox;
//           return Positioned(
//             left: rect.left * scaleX,
//             top: rect.top * scaleY,
//             width: rect.width * scaleX,
//             height: rect.height * scaleY,
//             child: Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.red, width: 2),
//               ),
//               child: Text(
//                 '${box.classId} ${(box.confidence * 100).toStringAsFixed(1)}%',
//                 style: const TextStyle(
//                   color: Colors.red,
//                   fontSize: 12,
//                   backgroundColor: Colors.white,
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../core/detection_box.dart';

class DetectionOverlay extends StatelessWidget {
  final List<DetectionBox> boxes;
  final double imageWidth;
  final double imageHeight;
  final double renderWidth;
  final double renderHeight;

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
    final scaleX = renderWidth / imageWidth;
    final scaleY = renderHeight / imageHeight;

    return SizedBox(
      width: renderWidth,
      height: renderHeight,
      child: Stack(
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
      ),
    );
  }
}

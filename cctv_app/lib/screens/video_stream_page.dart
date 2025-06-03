// import 'dart:typed_data';
// import 'package:flutter/material.dart';

// import '../core/detection_box.dart';
// import '../services/socket_service.dart';
// import '../widgets/detection_overlay.dart';
// import '../widgets/single_stream_widget.dart';

// class MultiStreamPage extends StatefulWidget {
//   const MultiStreamPage({super.key});

//   @override
//   State<MultiStreamPage> createState() => _MultiStreamPageState();
// }

// class _MultiStreamPageState extends State<MultiStreamPage> {
//   final int streamCount = 9; // 2x2 그리드

//   // 각 스트림별 이미지와 감지 결과 관리
//   final List<Uint8List?> _images = List.filled(9, null); // ✅ 추가
//   final List<List<DetectionBox>> _boxesList = List.generate(9, (_) => []);
//   final List<bool> _connectedList = List.filled(9, false);
//   final List<SocketService> _socketServices = [];

//   @override
//   void initState() {
//     super.initState();
//     for (int i = 0; i < streamCount; i++) {
//       final socketService = SocketService(
//         id: i,
//         onDataReceived: (image, boxes, connected) {
//           setState(() {
//             _images[i] = image;
//             _boxesList[i] = boxes;
//             _connectedList[i] = connected;
//           });
//         },
//       );
//       socketService.connect();
//       _socketServices.add(socketService);
//     }
//   }

//   @override
//   void dispose() {
//     for (final service in _socketServices) {
//       service.disconnect();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
 
//     return Scaffold(
//       appBar: AppBar(title: const Text('멀티 CCTV 스트림')),
//       body: GridView.builder(
//         padding: const EdgeInsets.all(8),
//         itemCount: streamCount,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3, // 2x2 그리드
//           childAspectRatio: 16 / 9,
//           crossAxisSpacing: 8,
//           mainAxisSpacing: 8,
//         ),
//         itemBuilder: (_, index) {
//           return SingleStreamWidget(
//             imageData: _images[index],
//             boxes: _boxesList[index],
//             connected: _connectedList[index],
//           );
//         },
//       ),
//     );
//   }
// }


import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/detection_box.dart';
import '../services/socket_service.dart';
import '../widgets/single_stream_widget.dart';

class MultiStreamPage extends StatefulWidget {
  const MultiStreamPage({super.key});

  @override
  State<MultiStreamPage> createState() => _MultiStreamPageState();
}

class _MultiStreamPageState extends State<MultiStreamPage> {
  final int streamCount = 9;

  final List<Uint8List?> _images = List.filled(9, null);
  final List<List<DetectionBox>> _boxesList = List.generate(9, (_) => []);
  final List<bool> _connectedList = List.filled(9, false);
  final List<SocketService> _socketServices = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < streamCount; i++) {
      final socketService = SocketService(
        id: i,
        onDataReceived: (image, boxes, connected) {
          setState(() {
            _images[i] = image;
            _boxesList[i] = boxes;
            _connectedList[i] = connected;
          });
        },
      );
      socketService.connect();
      _socketServices.add(socketService);
    }
  }

  @override
  void dispose() {
    for (final service in _socketServices) {
      service.disconnect();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('멀티 CCTV 스트림')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: streamCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 16 / 9,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (_, index) {
          return SingleStreamWidget(
            imageData: _images[index],
            boxes: _boxesList[index],
            connected: _connectedList[index],
          );
        },
      ),
    );
  }
}

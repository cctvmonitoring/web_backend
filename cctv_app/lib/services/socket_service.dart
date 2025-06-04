// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:socket_io_client/socket_io_client.dart' as IO;

// import '../core/detection_box.dart';

// import 'dart:ui';

// class SocketService {
//   final int id; // 👈 추가: 포트 번호 계산용
//   final Function(Uint8List?, List<DetectionBox>, bool connected) onDataReceived;

//   late IO.Socket _socket;
//   bool _connected = false;

//   SocketService({required this.id ,required this.onDataReceived});

//   void connect() {
//     final int port = 3000 + id;
//     final String url = 'http://192.168.1.10:$port';

//     _socket = IO.io(url, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//       'reconnectionAttempts': 3,
//       'reconnectionDelay': 1000,
//     });

//     _socket.onConnect((_) {
//       _connected = true;
//       print('✅ [포트 $port] 연결됨');
//     });

//     _socket.onConnectError((_) {
//       _connected = false;
//       onDataReceived(null, [], false); // 연결 실패 UI 표시
//     });

//     _socket.onError((_) {
//       _connected = false;
//       onDataReceived(null, [], false);
//     });

//     _socket.on('stream', (data) {
//       try {
//         final decoded = jsonDecode(data);
//         final imageBytes = base64Decode(decoded['image']);
//         final detections = <DetectionBox>[];

//         for (var det in decoded['detections']) {
//           final rect = Rect.fromLTRB(
//             det['bbox'][0].toDouble(),
//             det['bbox'][1].toDouble(),
//             det['bbox'][2].toDouble(),
//             det['bbox'][3].toDouble(),
//           );
//           detections.add(DetectionBox(det['class_id'], det['confidence'].toDouble(), rect));
//         }

//         onDataReceived(imageBytes, detections, true); // 정상 수신
//       } catch (e) {
//         onDataReceived(null, [], false); // 예외 발생 시 연결 실패 처리
//       }
//     });

//     _socket.connect();
//   }

//   void disconnect() {
//     _socket.disconnect();
//     _socket.dispose();
//   }
// }

import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../core/detection_box.dart';

class SocketService {
  final Function(Uint8List?, List<DetectionBox>, bool connected, String streamId) onDataReceived;

  late IO.Socket _socket;

  SocketService({required this.onDataReceived});

  void connect() {
    final url = 'http://192.168.1.10:3000'; // 하나의 포트만 사용

    _socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) {
      print('✅ Socket.IO connected');
    });

    _socket.onError((_) => onDataReceived(null, [], false, ''));
    _socket.onConnectError((_) => onDataReceived(null, [], false, ''));

    // stream1 ~ stream9 구독
    for (int i = 1; i <= 9; i++) {
      final streamName = 'stream$i';
      _socket.on(streamName, (data) {
        _handleStream(data, streamName);
      });
    }

    _socket.connect();
  }

  void _handleStream(dynamic data, String streamId) {
    try {
      final decoded = data;
      final imageBytes = base64Decode(decoded['image']);
      final detections = <DetectionBox>[];

      for (var det in decoded['detections']) {
        final rect = Rect.fromLTRB(
          det['bbox'][0].toDouble(),
          det['bbox'][1].toDouble(),
          det['bbox'][2].toDouble(),
          det['bbox'][3].toDouble(),
        );
        detections.add(
          DetectionBox(det['class_id'], det['confidence'].toDouble(), rect),
        );
      }

      onDataReceived(imageBytes, detections, true, streamId);
    } catch (e) {
      onDataReceived(null, [], false, streamId);
    }
  }

  void disconnect() {
    _socket.disconnect();
    _socket.dispose();
  }
}


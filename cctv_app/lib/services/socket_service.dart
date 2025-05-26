import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../core/detection_box.dart';

import 'dart:ui';

/// 소켓 통신을 통해 CCTV 영상 스트림과 객체 감지 결과를 수신하는 서비스 클래스
class SocketService {
  /// 데이터를 수신했을 때 호출되는 콜백 (이미지, 감지 결과)
  final Function(Uint8List image, List<DetectionBox> detections) onDataReceived;

  /// Socket.IO 클라이언트 인스턴스
  late IO.Socket _socket;

  /// 프레임 수신 간격을 제어하는 타이머 (100ms)
  Timer? _frameTimer;
  final Duration _frameInterval = Duration(milliseconds: 100);

  /// 생성자: 데이터 수신 콜백을 전달받음
  SocketService({required this.onDataReceived});

  /// 소켓 서버에 연결하고, 데이터 수신 이벤트를 등록
  void connect() {
    _socket = IO.io('http://192.168.1.10:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000
    });

    // 소켓 연결 성공 시 로그 출력
    _socket.onConnect((_) {
      print('✅ Socket.IO 연결됨');
    });

    // 'stream' 이벤트로 이미지와 감지 결과 수신
    _socket.on('stream', (data) {
      try {
        // JSON 데이터 디코딩
        final decoded = jsonDecode(data);
        // base64 인코딩된 이미지 디코딩
        final imageBytes = base64Decode(decoded['image']);
        final detections = <DetectionBox>[];

        // 감지된 객체 리스트 파싱
        for (var det in decoded['detections']) {
          final x1 = det['bbox'][0].toDouble();
          final y1 = det['bbox'][1].toDouble();
          final x2 = det['bbox'][2].toDouble();
          final y2 = det['bbox'][3].toDouble();

          detections.add(DetectionBox(
            det['class_id'],
            det['confidence'].toDouble(),
            Rect.fromLTRB(x1, y1, x2, y2),
          ));
        }

        // 프레임 간격에 맞춰 콜백 호출 (100ms마다 1회)
        if (_frameTimer == null || !_frameTimer!.isActive) {
          onDataReceived(imageBytes, detections);
          _frameTimer = Timer(_frameInterval, () {});
        }
      } catch (e) {
        print('[SocketService] 수신 에러: $e');
      }
    });

    // 소켓 연결 시작
    _socket.connect();
  }

  /// 소켓 연결 해제 및 리소스 정리
  void disconnect() {
    _socket.disconnect();
    _socket.dispose();
  }
}

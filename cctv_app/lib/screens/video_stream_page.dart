import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../core/detection_box.dart';
import '../services/socket_service.dart';
import '../widgets/detection_overlay.dart';

/// CCTV 영상 스트림을 보여주는 페이지
class VideoStreamPage extends StatefulWidget {
  const VideoStreamPage({super.key});

  @override
  State<VideoStreamPage> createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  /// 수신한 이미지 데이터 (바이트 배열)
  Uint8List? _imageData;

  /// 감지된 객체들의 바운딩 박스 리스트
  List<DetectionBox> _boxes = [];

  /// 소켓 통신 서비스
  late SocketService _socketService;

  /// 위젯이 생성될 때 소켓 연결 및 데이터 수신 콜백 등록
  @override
  void initState() {
    super.initState();
    _socketService = SocketService(onDataReceived: _onStreamData);
    _socketService.connect();
  }

  /// 소켓을 통해 이미지와 감지 결과를 수신했을 때 호출되는 함수
  void _onStreamData(Uint8List image, List<DetectionBox> boxes) {
    setState(() {
      _imageData = image;
      _boxes = boxes;
    });
  }

  /// 위젯이 dispose될 때 소켓 연결 해제
  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  /// UI 빌드: 이미지와 감지 결과 오버레이 표시
  @override
  Widget build(BuildContext context) {
    // 화면 크기에 맞춰 이미지 렌더링 크기 계산
    final imageRenderWidth = MediaQuery.of(context).size.width;
    final imageRenderHeight = MediaQuery.of(context).size.height * 0.7;

    // 원본 이미지의 해상도 (감지 결과 위치 변환에 사용)
    final originalImageWidth = 1920;
    final originalImageHeight = 1080;

    return Scaffold(
      appBar: AppBar(title: const Text('CCTV 스트림')),
      body: Center(
        child: _imageData == null
            // 이미지 데이터가 없으면 로딩 인디케이터 표시
            ? const CircularProgressIndicator()
            // 이미지와 감지 결과 오버레이를 Stack으로 표시
            : Stack(
                children: [
                    // 수신한 이미지를 화면에 표시
                    Image.memory(
                    _imageData!,
                    gaplessPlayback: true,
                    fit: BoxFit.contain,
                    width: imageRenderWidth,
                    height: imageRenderHeight,
                    ),
                    // 감지 결과(바운딩 박스) 오버레이
                    DetectionOverlay(
                    boxes: _boxes,
                    imageWidth: originalImageWidth.toDouble(),
                    imageHeight: originalImageHeight.toDouble(),
                    renderWidth: imageRenderWidth,
                    renderHeight: imageRenderHeight,
                    ),
                ],
            ),
       ),
    );
  }
}

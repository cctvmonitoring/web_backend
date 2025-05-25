import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:typed_data';
import 'dart:js_util' as js_util;


// 백엔드와 연결을 위한 예시 플러터 코드드
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CCTV Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VideoStreamPage(),
    );
  }
}

class VideoStreamPage extends StatefulWidget {
  const VideoStreamPage({super.key});

  @override
  State<VideoStreamPage> createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  IO.Socket? _socket;
  bool _isConnected = false;
  String _statusMessage = '연결 중...';
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  void _connectSocket() {
    try {
      _socket = IO.io('http://192.168.1.21:3000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000
      });

      _socket!.onConnect((_) {
        print('Socket.IO 연결됨');
        setState(() {
          _isConnected = true;
          _statusMessage = '스트림 수신 중...';
        });
      });

      _socket!.onDisconnect((_) {
        print('Socket.IO 연결 끊김');
        setState(() {
          _isConnected = false;
          _statusMessage = '연결이 끊어졌습니다. 재연결 시도 중...';
        });
      });

      _socket!.onError((error) {
        print('Socket.IO 에러: $error');
        setState(() {
          _isConnected = false;
          _statusMessage = '연결 오류: $error';
        });
      });

      _socket!.on('stream', (data) {
        print('수신 데이터 타입: ${data.runtimeType}');
        print('수신 데이터: $data');
        if (data is List<int>) {
          setState(() {
            _imageData = Uint8List.fromList(data);
            _isConnected = true;
            _statusMessage = '스트림 수신 중...';
          });
        } else if (data is Uint8List) {
          setState(() {
            _imageData = data;
            _isConnected = true;
            _statusMessage = '스트림 수신 중...';
          });
        } else if (data is ByteBuffer) {
          final bytes = Uint8List.view(data);
          setState(() {
            _imageData = bytes;
            _isConnected = true;
            _statusMessage = '스트림 수신 중...';
          });
        }
      });

      _socket!.connect();
    } catch (e) {
      print('연결 시도 실패: $e');
      setState(() {
        _statusMessage = '연결 실패: $e';
      });
    }
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CCTV 스트림'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _statusMessage = '재연결 시도 중...';
              });
              _socket?.disconnect();
              _connectSocket();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isConnected)
              const CircularProgressIndicator()
            else if (_imageData != null)
              Image.memory(
                _imageData!,
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.7,
              )
            else
              const Text('스트림이 연결되었습니다.'),
            const SizedBox(height: 20),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }
} 
// // import 'package:flutter/material.dart';
// // import 'package:socket_io_client/socket_io_client.dart' as IO;
// // import 'dart:typed_data';
// // import 'dart:js_util' as js_util;
// // import 'dart:async';



// // // 백엔드와 연결을 위한 예시 플러터 코드드
// // void main() {
// //   runApp(const MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'CCTV Viewer',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: const VideoStreamPage(),
// //     );
// //   }
// // }

// // class VideoStreamPage extends StatefulWidget {
// //   const VideoStreamPage({super.key});

// //   @override
// //   State<VideoStreamPage> createState() => _VideoStreamPageState();
// // }

// // class _VideoStreamPageState extends State<VideoStreamPage> {
// //   IO.Socket? _socket;
// //   bool _isConnected = false;
// //   String _statusMessage = '연결 중...';
// //   Uint8List? _imageData;

// //   Timer? _frameTimer;
// //   final _frameInterval = Duration(milliseconds: 100);

// //   @override
// //   void initState() {
// //     super.initState();
// //     _connectSocket();
// //   }

// //   void _connectSocket() {
// //     try {
// //       _socket = IO.io('http://192.168.1.10:3000', <String, dynamic>{
// //         'transports': ['websocket'],
// //         'autoConnect': true,
// //         'reconnection': true,
// //         'reconnectionAttempts': 5,
// //         'reconnectionDelay': 1000
// //       });

// //       _socket!.onConnect((_) {
// //         print('Socket.IO 연결됨');
// //         setState(() {
// //           _isConnected = true;
// //           _statusMessage = '스트림 수신 중...';
// //         });
// //       });

// //       _socket!.onDisconnect((_) {
// //         print('Socket.IO 연결 끊김');
// //         setState(() {
// //           _isConnected = false;
// //           _statusMessage = '연결이 끊어졌습니다. 재연결 시도 중...';
// //         });
// //       });

// //       _socket!.onError((error) {
// //         print('Socket.IO 에러: $error');
// //         setState(() {
// //           _isConnected = false;
// //           _statusMessage = '연결 오류: $error';
// //         });
// //       });

// //       _socket!.on('stream', (data) {
// //         try {
// //           Uint8List bytes;

// //           if (data is Uint8List) {
// //             bytes = data;
// //           } else if (data is List<int>) {
// //             bytes = Uint8List.fromList(data);
// //           } else if (data is ByteBuffer) {
// //             bytes = Uint8List.view(data);
// //           } else {
// //             print('[Flutter] ⚠️ 지원하지 않는 타입: ${data.runtimeType}');
// //             return;
// //           }

// //           // 프레임 처리 제한 (10fps)
// //           if (_frameTimer == null || !_frameTimer!.isActive) {
// //             setState(() {
// //               _imageData = bytes;
// //               _isConnected = true;
// //               _statusMessage = '스트림 수신 중...';
// //             });

// //             _frameTimer = Timer(_frameInterval, () {});
// //           }
// //         } catch (e) {
// //           print('[Flutter] ⚠️ 이미지 처리 중 오류: $e');
// //         }
// //       });
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _socket?.disconnect();
// //     _socket?.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('CCTV 스트림'),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.refresh),
// //             onPressed: () {
// //               setState(() {
// //                 _statusMessage = '재연결 시도 중...';
// //               });
// //               _socket?.disconnect();
// //               _connectSocket();
// //             },
// //           ),
// //         ],
// //       ),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             if (!_isConnected)
// //               const CircularProgressIndicator()
// //             else if (_imageData != null)
// //               Image.memory(
// //                 _imageData!,
// //                 fit: BoxFit.contain,
// //                 width: MediaQuery.of(context).size.width,
// //                 height: MediaQuery.of(context).size.height * 0.7,
// //               )
// //             else
// //               const Text('스트림이 연결되었습니다.'),
// //             const SizedBox(height: 20),
// //             Text(_statusMessage),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // } 

// import 'package:flutter/material.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'dart:typed_data';
// import 'dart:async';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'CCTV Viewer',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const VideoStreamPage(),
//     );
//   }
// }


// class VideoStreamPage extends StatefulWidget {
//   const VideoStreamPage({super.key});

//   @override
//   State<VideoStreamPage> createState() => _VideoStreamPageState();
// }

// class _VideoStreamPageState extends State<VideoStreamPage> {
//   IO.Socket? _socket;
//   bool _isConnected = false;
//   String _statusMessage = '연결 중...';
//   Uint8List? _imageData;

//   Timer? _frameTimer;
//   final Duration _frameInterval = Duration(milliseconds: 100); // 10 FPS 제한

//   @override
//   void initState() {
//     super.initState();
//     _connectSocket();
//   }

//   void _connectSocket() {
//     try {
//       _socket = IO.io('http://192.168.1.10:3000', <String, dynamic>{
//         'transports': ['websocket'],
//         'autoConnect': true,
//         'reconnection': true,
//         'reconnectionAttempts': 5,
//         'reconnectionDelay': 1000
//       });

//       _socket!.onConnect((_) {
//         print('✅ Socket.IO 연결됨');
//         setState(() {
//           _isConnected = true;
//           _statusMessage = '스트림 수신 중...';
//         });
//       });

//       _socket!.onDisconnect((_) {
//         print('⚠️ Socket.IO 연결 끊김');
//         setState(() {
//           _isConnected = false;
//           _statusMessage = '연결이 끊어졌습니다. 재연결 시도 중...';
//         });
//       });

//       _socket!.onError((error) {
//         print('❌ Socket.IO 에러: $error');
//         setState(() {
//           _isConnected = false;
//           _statusMessage = '연결 오류: $error';
//         });
//       });

//       _socket!.on('stream', (data) {
//         try {
//           Uint8List bytes;

//           if (data is Uint8List) {
//             bytes = data;
//           } else if (data is List<int>) {
//             bytes = Uint8List.fromList(data);
//           } else if (data is ByteBuffer) {
//             bytes = Uint8List.view(data);
//           } else {
//             print('[Flutter] ⚠️ 지원하지 않는 타입: ${data.runtimeType}');
//             return;
//           }

//           if (_frameTimer == null || !_frameTimer!.isActive) {
//             setState(() {
//               _imageData = bytes;
//               _isConnected = true;
//               _statusMessage = '스트림 수신 중...';
//             });

//             _frameTimer = Timer(_frameInterval, () {});
//           }
//         } catch (e) {
//           print('[Flutter] ⚠️ 이미지 처리 중 오류: $e');
//         }
//       });

//       _socket!.connect();
//     } catch (e) {
//       print('❌ 연결 시도 실패: $e');
//       setState(() {
//         _statusMessage = '연결 실패: $e';
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _socket?.disconnect();
//     _socket?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('CCTV 스트림'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () {
//               setState(() {
//                 _statusMessage = '재연결 시도 중...';
//               });
//               _socket?.disconnect();
//               _connectSocket();
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (!_isConnected)
//               const CircularProgressIndicator()
//             else if (_imageData != null)
//               Image.memory(
//                 _imageData!,
//                 gaplessPlayback: true, // 깜빡임 방지
//                 fit: BoxFit.contain,
//                 width: MediaQuery.of(context).size.width,
//                 height: MediaQuery.of(context).size.height * 0.7,
//               )
//             else
//               const Text('스트림이 연결되었습니다.'),
//             const SizedBox(height: 20),
//             Text(_statusMessage),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  runApp(const MyApp());
}

// const express = require('express');
// const app = express();
// const http = require('http').createServer(app);
// const io = require('socket.io')(http, {
//   cors: {
//     origin: "*",
//     methods: ["GET", "POST"]
//   }
// });
// const WebSocket = require('ws');

// // 미들웨어 설정
// app.use(express.json());
// app.use(express.urlencoded({ extended: true }));
// app.use(express.static('public'));

// // 기본 라우트
// app.get('/', (req, res) => {
//   res.send('CCTV Backend Server is running');
// });

// // 에러 핸들링 미들웨어
// app.use((err, req, res, next) => {
//   console.error('서버 에러:', err);
//   res.status(500).send('서버 에러가 발생했습니다.');
// });

// // 라즈베리파이 카메라 스트림 연결
// const raspberryPiUrl = 'ws://192.168.1.22:5000';
// let ws;

// function connectToRaspberryPi() {
//   ws = new WebSocket(raspberryPiUrl);

//   ws.on('open', () => {
//     console.log('라즈베리파이 카메라 스트림에 연결됨');
//   });

//   ws.on('message', (data) => {
//     try {
//       // 이미지 데이터를 그대로 전송
//       io.emit('stream', data);
//     } catch (error) {
//       console.error('스트림 데이터 처리 중 에러:', error);
//     }
//   });

//   ws.on('error', (error) => {
//     console.error('WebSocket 에러:', error);
//   });

//   ws.on('close', () => {
//     console.log('라즈베리파이 연결이 끊어짐. 재연결 시도...');
//     setTimeout(connectToRaspberryPi, 5000);
//   });
// }

// // Socket.IO 클라이언트 연결 처리
// io.on('connection', (socket) => {
//   console.log('클라이언트 연결됨');

//   socket.on('disconnect', () => {
//     console.log('클라이언트 연결 끊김');
//   });
// });

// // 서버 시작
// const PORT = process.env.PORT || 3000;
// http.listen(PORT, () => {
//   console.log(`서버가 포트 ${PORT}에서 실행 중입니다`);
//   connectToRaspberryPi();
// }); 

// ✅ WebSocket 서버 설정 추가
const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 5000 });  // YOLO 서버가 연결

// Socket.IO 그대로 유지
const express = require('express');
const app = express();
const http = require('http').createServer(app);
const io = require('socket.io')(http, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// 정적 파일 및 라우팅 설정
app.use(express.static('public'));
app.get('/', (req, res) => {
  res.send('CCTV Backend Server is running');
});

// ✅ WebSocket 연결 처리 (YOLO 서버가 연결)
wss.on('connection', function connection(ws) {
  console.log('[WebSocket] YOLO Server connected');

  // ws.on('message', function incoming(data) {
  //   // YOLO에서 받은 프레임을 Flutter로 전달
  //   io.emit('stream', data);
  // });
  ws.on('message', function incoming(data) {
    try {
      const jsonString = data.toString();  // ✅ Buffer → 문자열
      io.emit('stream', jsonString);       // ✅ Flutter에서 String으로 받음
    } catch (e) {
      console.error('[WebSocket] JSON 변환 실패:', e);
    }
  });


  ws.on('close', () => {
    console.log('[WebSocket] YOLO Server disconnected');
  });

  ws.on('error', (err) => {
    console.error('[WebSocket] Error:', err);
  });
});

// Socket.IO (Flutter 클라이언트)
io.on('connection', (socket) => {
  console.log('[Socket.IO] Flutter client connected');

  socket.on('disconnect', () => {
    console.log('[Socket.IO] Flutter client disconnected');
  });
});

const PORT = process.env.PORT || 3000;
http.listen(PORT, () => {
  console.log(`✅ Node.js server running on port ${PORT}`);
});

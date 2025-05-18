const express = require('express');
const app = express();
const http = require('http').createServer(app);
const io = require('socket.io')(http, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});
const WebSocket = require('ws');

// 정적 파일 제공
app.use(express.static('public'));

// 라즈베리파이 카메라 스트림 연결
function connectToRaspberryPi() {
  // 라즈베리파이의 스트리밍 서버에 연결
  const raspberryPiUrl = 'ws://라즈베리파이_IP:8080';  // 라즈베리파이 IP로 변경 필요
  const ws = new WebSocket(raspberryPiUrl);

  ws.on('open', () => {
    console.log('Connected to Raspberry Pi camera stream');
  });

  ws.on('message', (data) => {
    // 연결된 모든 클라이언트에게 영상 데이터 전달
    io.emit('stream', data);
  });

  ws.on('error', (error) => {
    console.error('WebSocket error:', error);
    // 연결 재시도
    setTimeout(connectToRaspberryPi, 5000);
  });

  ws.on('close', () => {
    console.log('Disconnected from Raspberry Pi');
    // 연결 재시도
    setTimeout(connectToRaspberryPi, 5000);
  });

  return ws;
}

// Socket.IO 클라이언트 연결 처리
io.on('connection', (socket) => {
  console.log('Client connected');

  socket.on('disconnect', () => {
    console.log('Client disconnected');
  });
});

// 서버 시작
const PORT = process.env.PORT || 3000;
http.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  // 라즈베리파이 연결 시작
  connectToRaspberryPi();
}); 
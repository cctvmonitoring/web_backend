import asyncio
import websockets
import io
from picamera2 import Picamera2
from picamera2.encoders import JpegEncoder
from picamera2.outputs import FileOutput

# 카메라 초기화
picam2 = Picamera2()
config = picam2.create_video_configuration(main={"size": (640, 480)})
picam2.configure(config)
picam2.start()

# 스트림 출력을 위한 클래스
class StreamingOutput(io.BufferedIOBase):
    def __init__(self):
        self.frame = None
        self.condition = asyncio.Condition()

    def write(self, buf):
        with self.condition:
            self.frame = buf
            self.condition.notify_all()

# WebSocket 서버 핸들러
async def stream_handler(websocket):
    print("Client connected")
    output = StreamingOutput()
    encoder = JpegEncoder(q=70)
    picam2.start_encoder(encoder, FileOutput(output))

    try:
        while True:
            async with output.condition:
                await output.condition.wait()
                if output.frame is not None:
                    await websocket.send(output.frame)
    except websockets.exceptions.ConnectionClosed:
        print("Client disconnected")
    finally:
        picam2.stop_encoder()

# WebSocket 서버 시작
async def main():
    server = await websockets.serve(stream_handler, "0.0.0.0", 8080)
    print("Camera streaming server started on ws://0.0.0.0:8080")
    await server.wait_closed()

# 서버 실행
asyncio.run(main()) 
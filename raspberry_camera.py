import cv2
import asyncio
import websockets
import numpy as np
from picamera2 import Picamera2
import face_recognition

# 라즈베리 파이 예시코드드

# 카메라 초기화
picam2 = Picamera2()
config = picam2.create_video_configuration(main={"size": (640, 480)})
picam2.configure(config)
picam2.start()

# 얼굴 인식 설정
face_locations = []
face_encodings = []

async def stream_camera(websocket):
    try:
        while True:
            # 카메라에서 프레임 캡처
            frame = picam2.capture_array()
            
            # BGR에서 RGB로 변환 (face_recognition은 RGB 사용)
            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            
            # 얼굴 위치 찾기 (성능 향상을 위해 1/4 크기로 처리)
            small_frame = cv2.resize(rgb_frame, (0, 0), fx=0.25, fy=0.25)
            face_locations = face_recognition.face_locations(small_frame)
            
            # 얼굴 인코딩
            face_encodings = face_recognition.face_encodings(small_frame, face_locations)
            
            # 얼굴 위치를 원본 크기로 변환
            face_locations = [(top * 4, right * 4, bottom * 4, left * 4) 
                            for (top, right, bottom, left) in face_locations]
            
            # 얼굴 주변에 박스 그리기
            for (top, right, bottom, left) in face_locations:
                cv2.rectangle(frame, (left, top), (right, bottom), (0, 255, 0), 2)
                cv2.putText(frame, "Face", (left, top - 10), 
                          cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
            
            # BGR에서 JPEG로 인코딩
            _, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 80])
            
            # WebSocket을 통해 전송
            await websocket.send(buffer.tobytes())
            
            # 약간의 지연 추가 (20 FPS에 가깝게)
            await asyncio.sleep(0.05)
            
    except websockets.exceptions.ConnectionClosed:
        print("클라이언트 연결이 종료되었습니다.")
    except Exception as e:
        print(f"에러 발생: {e}")

async def main():
    # WebSocket 서버 시작
    server = await websockets.serve(stream_camera, "0.0.0.0", 8080)
    print("카메라 스트리밍 서버가 시작되었습니다. (포트: 8080)")
    await server.wait_closed()

if __name__ == "__main__":
    asyncio.run(main()) 
# 실행 방법

## 1. 라즈베리파이에서 카메라 스트리밍 서버 실행

 python raspberry_camera.py
 
- 실행 후 터미널에 다음 같은 문구가 출력되어야 합니다: "카메라 스트리밍 서버가 시작되었습니다. (포트: 8080)"
---

## 2. Node 서버 실행

node server.js
## 3. Flutter 웹 실행
cd cctv_app <br>(Flutter 코드가 있는 디렉토리로 이동)

flutter run -d chrome
<br>(Flutter 웹 실행 명령어)


## 4. 안드로이드 앱 패키징
apk 추출 명령어
cd ~/{project-root}
flutter build apk --release --target-platform=android-arm64

예시:
cd C:\Users\LG\Documents\GitHub\web_backend\cctv_app;
flutter build apk --release --target-platform=android-arm64

> **참고:**  
> 각 단계별로 Python, Node.js, Flutter가 설치되어 있어야 합니다.  

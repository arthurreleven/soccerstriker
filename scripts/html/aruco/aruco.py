import cv2
import cv2.aruco as aruco
import socket, json, math

cap = cv2.VideoCapture(0)
dictionary = aruco.getPredefinedDictionary(aruco.DICT_4X4_50)
params = aruco.DetectorParameters()
detector = aruco.ArucoDetector(dictionary, params)

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

while True:
    ret, frame = cap.read()
    if not ret:
        continue
    
    cv2.imshow("Camera", frame)  # adiciona isso
    if cv2.waitKey(1) == ord('q'):
        break

    corners, ids, _ = detector.detectMarkers(frame)

    if ids is not None:
        c  = corners[0][0]
        cx = float(c[:, 0].mean())
        cy = float(c[:, 1].mean())

        # calcula ângulo pela borda superior do marcador
        dx = c[1][0] - c[0][0]
        dy = c[1][1] - c[0][1]
        angle = math.degrees(math.atan2(dy, dx))

        data = json.dumps({"detected": True, "x": cx, "y": cy, "angle": angle})
        print(f"Detectado! x={cx:.0f} y={cy:.0f} angle={angle:.1f}")
    else:
        data = json.dumps({"detected": False})
        print("Não detectado") 

    sock.sendto(data.encode(), ("192.168.1.7", 5005))
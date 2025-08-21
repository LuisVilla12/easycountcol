import cv2
import numpy as np
import matplotlib.pyplot as plt
import argparse


ap = argparse.ArgumentParser()
ap.add_argument("-i", "--image", required=True, help="Colocar la ruta de la imagen")
args = vars(ap.parse_args())

# Cargar la imagen tomando el arugmento de la línea de comandos
img = cv2.imread(args["image"])

gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
gray = cv2.medianBlur(gray, 5)

# Detección de círculos (Hough)
circles = cv2.HoughCircles(
    gray, 
    cv2.HOUGH_GRADIENT, dp=1.2, minDist=100,
    param1=50, param2=30, minRadius=100, maxRadius=300
)

# Dibujar círculos detectados
output = img.copy()
if circles is not None:
    circles = np.uint16(np.around(circles))
    for (x, y, r) in circles[0, :]:
        cv2.circle(output, (x, y), r, (0, 255, 0), 2)   # borde del círculo
        cv2.circle(output, (x, y), 2, (255, 0, 0), 3)   # centro

# Mostrar con matplotlib (plt)
plt.figure(figsize=(8,8))
plt.imshow(cv2.cvtColor(output, cv2.COLOR_BGR2RGB))
plt.axis("off")
plt.title("Círculo detectado (caja Petri)")
plt.show()

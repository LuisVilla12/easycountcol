from skimage.feature import peak_local_max
from skimage.segmentation import watershed
from scipy import ndimage
import numpy as np
import argparse
import imutils
import cv2
import matplotlib.pyplot as plt

# ==========================
# Analizar los argumentos de línea de comandos
# ==========================
ap = argparse.ArgumentParser()
ap.add_argument("-i", "--image", required=True, help="path to input image")
args = vars(ap.parse_args())

# ==========================
# Cargar imagen
# ==========================
image = cv2.imread(args["image"])
imageOriginal = cv2.cvtColor(image.copy(), cv2.COLOR_BGR2RGB)  # Para mostrar en Matplotlib
shifted = cv2.pyrMeanShiftFiltering(image, 21, 51)

# ==========================
# 1️⃣ Detectar círculo de la caja Petri
# ==========================
gray_circle = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
gray_circle = cv2.medianBlur(gray_circle, 5)

circles = cv2.HoughCircles(
    gray_circle,
    cv2.HOUGH_GRADIENT,
    dp=1.2,
    minDist=100,
    param1=50,
    param2=30,
    minRadius=100,
    maxRadius=0
)

mask_petri = np.zeros_like(gray_circle, dtype=np.uint8)
if circles is not None:
    circles = np.uint16(np.around(circles))
    for (x, y, r) in circles[0, :1]:  # Tomar solo el más grande
        cv2.circle(mask_petri, (x, y), r, 255, -1)

# ==========================
# 2️⃣ Escala de grises + Otsu
# ==========================
gray = cv2.cvtColor(shifted, cv2.COLOR_BGR2GRAY)
thresh = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)[1]

# Aplicar la máscara de la caja Petri
if circles is not None:
    thresh = cv2.bitwise_and(thresh, mask_petri)

# ==========================
# 3️⃣ Calcular distancia euclidiana
# ==========================
D = ndimage.distance_transform_edt(thresh)

# ==========================
# 4️⃣ Buscar máximos locales
# ==========================
coordinates = peak_local_max(D, min_distance=20, labels=thresh)

# Crear máscara booleana
localMax = np.zeros_like(D, dtype=bool)
localMax[tuple(coordinates.T)] = True

# Etiquetar marcadores
markers = ndimage.label(localMax, structure=np.ones((3, 3)))[0]

# ==========================
# 5️⃣ Aplicar Watershed
# ==========================
labels = watershed(-D, markers, mask=thresh)

# ==========================
# 6️⃣ Mostrar cantidad detectada
# ==========================
print(f"[INFO] {len(np.unique(labels)) - 1} colonias detectadas")

# ==========================
# 7️⃣ Dibujar resultados
# ==========================
output = image.copy()
for label in np.unique(labels):
    if label == 0:
        continue
    mask = np.zeros(gray.shape, dtype="uint8")
    mask[labels == label] = 255
    cnts = cv2.findContours(mask.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    cnts = imutils.grab_contours(cnts)
    c = max(cnts, key=cv2.contourArea)
    ((x, y), r) = cv2.minEnclosingCircle(c)
    cv2.circle(output, (int(x), int(y)), int(r), (0, 255, 0), 2)
    cv2.putText(output, f"#{label}", (int(x) - 10, int(y)),
                cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 255), 2)

output_rgb = cv2.cvtColor(output, cv2.COLOR_BGR2RGB)

# ==========================
# 8️⃣ Mostrar con Matplotlib
# ==========================
plt.figure(figsize=(12, 6))
plt.subplot(2, 3, 1)
plt.imshow(imageOriginal)
plt.title("Imagen original")
plt.axis("off")

plt.subplot(2, 3, 3)
plt.imshow(gray, cmap="gray")
plt.title("Gris")
plt.axis("off")

plt.subplot(2, 3, 4)
plt.imshow(thresh, cmap="gray")
plt.title("Umbral Otsu (solo dentro de Petri)")
plt.axis("off")

plt.subplot(2, 3, 5)
plt.imshow(D, cmap="jet")
plt.title("Mapa de distancia")
plt.axis("off")

plt.subplot(2, 3, 6)
plt.imshow(output_rgb)
plt.title("Colonias detectadas")
plt.axis("off")

plt.tight_layout()
plt.show()

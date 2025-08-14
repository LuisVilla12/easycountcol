from skimage.feature import peak_local_max
from skimage.segmentation import watershed
from scipy import ndimage
import numpy as np
import argparse
import imutils
import cv2
import matplotlib.pyplot as plt

# ---------- Analizar argumentos ----------
ap = argparse.ArgumentParser()
ap.add_argument("-i", "--image", required=True, help="path to input image")
args = vars(ap.parse_args())

# ---------- Cargar imagen y suavizar ----------
image = cv2.imread(args["image"])
shifted = cv2.pyrMeanShiftFiltering(image, 21, 51)
gray = cv2.cvtColor(shifted, cv2.COLOR_BGR2GRAY)

# ---------- 1️⃣ Detectar placa Petri ----------
gray_blur = cv2.medianBlur(gray, 5)
_, thresh_petri = cv2.threshold(gray_blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

contours, _ = cv2.findContours(thresh_petri.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
c = max(contours, key=cv2.contourArea)
mask_petri = np.zeros_like(gray, dtype="uint8")
cv2.drawContours(mask_petri, [c], -1, 255, -1)

# Suavizar máscara
mask_smooth = cv2.GaussianBlur(mask_petri, (21, 21), 0)

# ---------- 2️⃣ Mejorar contraste con CLAHE ----------
clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
gray_clahe = clahe.apply(gray)

# Aplicar máscara para trabajar solo dentro de la placa
gray_plate = cv2.bitwise_and(gray_clahe, gray_clahe, mask=mask_smooth)

# ---------- 3️⃣ Umbralización (Otsu) ----------
_, thresh = cv2.threshold(gray_plate, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
thresh = cv2.bitwise_not(thresh)  # Colonias en blanco

# ---------- 4️⃣ Limpieza ----------
kernel = np.ones((3, 3), np.uint8)
thresh = cv2.morphologyEx(thresh, cv2.MORPH_OPEN, kernel, iterations=1)

# ---------- 5️⃣ Watershed ----------
D = ndimage.distance_transform_edt(thresh)
min_distance = max(5, int(min(image.shape[:2]) * 0.015))  # dinámico
coordinates = peak_local_max(D, min_distance=min_distance, labels=thresh)
localMax = np.zeros_like(D, dtype=bool)
localMax[tuple(coordinates.T)] = True
markers = ndimage.label(localMax, structure=np.ones((3, 3)))[0]
labels = watershed(-D, markers, mask=thresh)

print(f"[INFO] {len(np.unique(labels)) - 1} colonias detectadas")

# ---------- 6️⃣ Dibujar resultados ----------
for label in np.unique(labels):
    if label == 0:
        continue
    mask = np.zeros(gray.shape, dtype="uint8")
    mask[labels == label] = 255
    cnts = cv2.findContours(mask.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    cnts = imutils.grab_contours(cnts)
    c = max(cnts, key=cv2.contourArea)
    ((x, y), r) = cv2.minEnclosingCircle(c)
    cv2.circle(image, (int(x), int(y)), int(r), (0, 255, 0), 2)
    cv2.putText(image, f"#{label}", (int(x)-10, int(y)),
                cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 255), 2)

# ---------- 7️⃣ Mostrar pasos intermedios ----------
plt.figure(figsize=(12, 6))

plt.subplot(2, 3, 1)
plt.imshow(gray, cmap="gray")
plt.title("Gris original")
plt.axis("off")

plt.subplot(2, 3, 2)
plt.imshow(mask_smooth, cmap="gray")
plt.title("Máscara placa")
plt.axis("off")

plt.subplot(2, 3, 3)
plt.imshow(gray_plate, cmap="gray")
plt.title("CLAHE dentro de placa")
plt.axis("off")

plt.subplot(2, 3, 4)
plt.imshow(thresh, cmap="gray")
plt.title("Umbral Otsu invertido")
plt.axis("off")

plt.subplot(2, 3, 5)
plt.imshow(D, cmap="jet")
plt.title("Mapa de distancia")
plt.axis("off")

plt.subplot(2, 3, 6)
plt.imshow(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
plt.title("Colonias detectadas")
plt.axis("off")

plt.tight_layout()
plt.show()

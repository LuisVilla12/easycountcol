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

# ---------- 1️⃣ Detectar placa Petri mediante contorno más grande ----------
gray_blur = cv2.medianBlur(gray, 5)
_, thresh_petri = cv2.threshold(gray_blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

contours, _ = cv2.findContours(thresh_petri.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
c = max(contours, key=cv2.contourArea)
mask_petri = np.zeros_like(gray, dtype="uint8")
cv2.drawContours(mask_petri, [c], -1, 255, -1)  # rellena solo dentro del Petri

# ---------- 2️⃣ Umbral Otsu solo dentro de la placa ----------
thresh = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]
thresh = cv2.bitwise_and(thresh, thresh, mask=mask_petri)

# ---------- 3️⃣ Eliminar bordes de la placa ----------
kernel = np.ones((5,5), np.uint8)
thresh = cv2.erode(thresh, kernel, iterations=1)

# ---------- 4️⃣ Watershed ----------
D = ndimage.distance_transform_edt(thresh)
coordinates = peak_local_max(D, min_distance=20, labels=thresh)
localMax = np.zeros_like(D, dtype=bool)
localMax[tuple(coordinates.T)] = True
markers = ndimage.label(localMax, structure=np.ones((3, 3)))[0]
labels = watershed(-D, markers, mask=thresh)

print(f"[INFO] {len(np.unique(labels)) - 1} colonias detectadas")

# ---------- 5️⃣ Dibujar resultados ----------
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
    cv2.putText(image, f"#{label}", (int(x) - 10, int(y)),
                cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 255), 2)

# ---------- 6️⃣ Mostrar ----------
plt.figure(figsize=(10,5))
plt.subplot(1, 2, 1)
plt.imshow(thresh, cmap="gray")
plt.title("Umbral + Recorte Petri")
plt.axis("off")

plt.subplot(1, 2, 2)
plt.imshow(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
plt.title("Colonias detectadas")
plt.axis("off")

plt.tight_layout()
plt.show()

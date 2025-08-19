from skimage.feature import peak_local_max
from skimage.segmentation import watershed
from scipy import ndimage
import numpy as np
import argparse
import imutils
import cv2
import matplotlib.pyplot as plt

ap = argparse.ArgumentParser()
ap.add_argument("-i", "--image", required=True, help="Colocar la ruta de la imagen")
args = vars(ap.parse_args())

# Cargar la imagen tomando el arugmento de la línea de comandos
image = cv2.imread(args["image"])
image_resultado = image.copy()  # Trabaja sobre una copia

# Filtro Gaussiano (reduce ruido fino)
imagen_suavizada=cv2.GaussianBlur(image,(5,5,),7)

# Filtro Mean Shift (suaviza regiones preservando bordes)
shifted = cv2.pyrMeanShiftFiltering(imagen_suavizada, 30,30)

gray = cv2.cvtColor(shifted, cv2.COLOR_BGR2GRAY)

# Detectar automáticamente el círculo de la caja Petri
circles = cv2.HoughCircles(
    gray, cv2.HOUGH_GRADIENT, dp=1.2, minDist=gray.shape[0]//2,
    param1=50, param2=30, minRadius=gray.shape[0]//4, maxRadius=gray.shape[0]//2
)

mask_circular = np.zeros(gray.shape, dtype="uint8")
if circles is not None:
    circles = np.round(circles[0, :]).astype("int")
    c = max(circles, key=lambda x: x[2])
    margen = int(0.15 * c[2])  # 3% del radio detectado, ajustable
    radio_mascara = c[2] - margen
    cv2.circle(mask_circular, (c[0], c[1]), radio_mascara, 255, -1)
    # cv2.circle(mask_circular, (c[0], c[1]), c[2] - 500, 255, -1)  # -10 para evitar más borde
    print(f"Círculo detectado: centro=({c[0]}, {c[1]}), radio={c[2]}")
else:
    # Si no se detecta círculo, usar el centro y radio por defecto
    center = (gray.shape[1] // 2, gray.shape[0] // 2)
    radius = min(center) - 10
    cv2.circle(mask_circular, center, radius, 255, -1)
    print(f"No se detectó círculo, usando centro=({center[0]}, {center[1]}), radio={radius}")

# Aplicar la máscara al umbral
thresh = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)[1]
thresh = cv2.bitwise_and(thresh, thresh, mask=mask_circular)

# Calcula el valor máximo del mapa de distancia para cada marcador
min_distancia = 10  # Ajusta según separación mínima esperada
umbral_distancia = 25  # Ajusta según el valor mínimo aceptable en el mapa de distancia

D = ndimage.distance_transform_edt(thresh)
coordinates = peak_local_max(D, min_distance=min_distancia, labels=thresh)

# Solo selecciona los máximos locales que superan el umbral
coordinates_filtradas = []
valores_umbral =[]
for coord in coordinates:
    # Guarda los valores del umbral
    valor = D[coord[0], coord[1]]
    if D[coord[0], coord[1]] > umbral_distancia:
        coordinates_filtradas.append(coord)
        # Agrega el valor a la lista
        valores_umbral.append(valor)
coordinates_filtradas = np.array(coordinates_filtradas)

# Imprime los valores
print("Valores del mapa de distancia en cada máximo local filtrado:")
for i, valor in enumerate(valores_umbral):
    print(f"Punto {i+1}: {valor}")
    
    
localMax = np.zeros_like(D, dtype=bool)
if len(coordinates_filtradas) > 0:
    localMax[tuple(coordinates_filtradas.T)] = True

# Etiquetar marcadores
markers = ndimage.label(localMax, structure=np.ones((3, 3)))[0]

# Aplicar Watershed
labels = watershed(-D, markers, mask=thresh)

# Mostrar cantidad detectada
# print(f"[INFO] {len(np.unique(labels)) - 1} etiquetas dectectadas (sin contar fondo)")

contador_colonias = 0  # Nuevo contador

# Dibujar resultados
for label in np.unique(labels):
    if label == 0:
        continue
    mask = np.zeros(gray.shape, dtype="uint8")
    mask[labels == label] = 255

    cnts = cv2.findContours(mask.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    cnts = imutils.grab_contours(cnts)

    if len(cnts) > 0:
        c = max(cnts, key=cv2.contourArea)
        area = cv2.contourArea(c)
        # 🔹 Filtrar por tamaño mínimo
        if  600<area>300:   # Ajusta los valores según tu imagen
            contador_colonias += 1
            ((x, y), r) = cv2.minEnclosingCircle(c)
            cv2.circle(image_resultado, (int(x), int(y)), int(r), (255, 255, 255), 6)
            cv2.putText(image_resultado, f"#{label}", (int(x) - 10, int(y)),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 10)

print(f"[INFO] {contador_colonias} colonias detectadas")

# Mostrar con Matplotlib
plt.figure(figsize=(14, 7))
plt.subplot(2, 4, 1)
plt.imshow(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
plt.title("Imagen original")
plt.axis("off")

plt.subplot(2, 4, 2)
plt.imshow(cv2.cvtColor(imagen_suavizada, cv2.COLOR_BGR2RGB))
plt.title("imagen suavizada")
plt.axis("off")

plt.subplot(2, 4, 3)
plt.imshow(gray, cmap="gray")
plt.title("Gris")
plt.axis("off")

plt.subplot(2, 4, 4)
plt.imshow(mask_circular, cmap="gray")
plt.title("Mascara circular")
plt.axis("off")

plt.subplot(2, 4, 5)
plt.imshow(thresh, cmap="gray")
plt.title("Umbral Otsu invertido")
plt.axis("off")

plt.subplot(2, 4, 6)
plt.imshow(D, cmap="jet")
plt.title("Mapa de distancia")
plt.axis("off")

plt.subplot(2, 4, 7)
# plt.imshow(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
plt.imshow(cv2.cvtColor(image_resultado, cv2.COLOR_BGR2RGB))
plt.title("Colonias detectadas")
plt.axis("off")

plt.tight_layout()
plt.show()

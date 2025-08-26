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

# Escala de grises
gray = cv2.cvtColor(shifted, cv2.COLOR_BGR2GRAY)

# Aplicar la máscara al umbral
thresh = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)[1]

# --- NUEVO: Operación morfológica para limpiar el borde ---
kernel = np.ones((5, 5), np.uint8)  # Puedes probar con (3,3) o (7,7) según el resultado
thresh = cv2.morphologyEx(thresh, cv2.MORPH_OPEN, kernel)

# Detectar automáticamente el círculo de la caja Petri
circles = cv2.HoughCircles(
    gray, cv2.HOUGH_GRADIENT, dp=1.2, minDist=gray.shape[0]//2,
    param1=50, param2=30, minRadius=gray.shape[0]//4, maxRadius=gray.shape[0]//2
)

mask_circular = np.zeros(gray.shape, dtype="uint8")
if circles is not None:
    circles = np.round(circles[0, :]).astype("int")
    c = max(circles, key=lambda x: x[2])
    radio_detectado = c[2]
    centro = (c[0], c[1])

    # Prueba márgenes crecientes hasta que la franja del borde tenga pocos píxeles blancos
    umbral_borde = 0.05  # Porcentaje máximo de píxeles blancos permitidos en la franja
    ancho_franja = 10    # Ancho de la franja en píxeles
    margen = 0
    while margen < int(0.1 * radio_detectado):  # No restar más del 20% del radio
        radio_interno = int(radio_detectado - margen - ancho_franja)
        radio_externo = int(radio_detectado - margen)
        # Crear máscara para la franja circular
        mascara_franja = np.zeros(gray.shape, dtype="uint8")
        cv2.circle(mascara_franja, centro, radio_externo, 255, -1)
        cv2.circle(mascara_franja, centro, radio_interno, 0, -1)
        # Aplica la franja a la imagen umbralizada
        pixeles_borde = cv2.bitwise_and(thresh, thresh, mask=mascara_franja)
        porcentaje_blancos = np.sum(pixeles_borde > 0) / np.sum(mascara_franja > 0)
        if porcentaje_blancos < umbral_borde:
            break
        margen += 2  # Aumenta el margen de a 2 píxeles

    radio_mascara = int(radio_detectado - margen)
    mask_circular = np.zeros(gray.shape, dtype="uint8")
    cv2.circle(mask_circular, centro, radio_mascara, 255, -1)
    print(f"Margen automático aplicado: {margen} píxeles (radio final: {radio_mascara})")

    # Erosiona la máscara circular para eliminar artefactos cercanos al borde (ajusta el factor si hace falta)
    # Usar erosión más suave para no eliminar colonias reales junto al borde
    erosion_px = max(1, int(0.003 * radio_mascara))
    kernel_ellipse = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (erosion_px*2+1, erosion_px*2+1))
    mask_circular_eroded = cv2.erode(mask_circular, kernel_ellipse, iterations=1)

    # Usa la máscara erosionada para el umbral final (evita falsos positivos en el borde)
    thresh = cv2.bitwise_and(thresh, thresh, mask=mask_circular_eroded)
    # Cerrar pequeños huecos para recuperar microcolonias pegadas al borde
    kernel_close = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    thresh = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel_close, iterations=1)
else:
    # Si no se detecta círculo, usar el centro y radio por defecto
    center = (gray.shape[1] // 2, gray.shape[0] // 2)
    radius = min(center) - 10
    cv2.circle(mask_circular, center, radius, 255, -1)
    print(f"No se detectó círculo, usando centro=({center[0]}, {center[1]}), radio={radius}")

    # Asegurar variables necesarias más adelante
    centro = center
    radio_mascara = radius
    erosion_px = max(3, int(0.03 * radio_mascara))
    kernel_ellipse = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (erosion_px*2+1, erosion_px*2+1))
    mask_circular_eroded = cv2.erode(mask_circular, kernel_ellipse, iterations=1)

# Después de generar mask_circular_eroded (tanto en if como en else) construye la franja
mask_edge = cv2.bitwise_xor(mask_circular, mask_circular_eroded)
thresh = cv2.bitwise_and(thresh, thresh, mask=mask_circular_eroded)

# Calcula el valor máximo del mapa de distancia para cada marcador
min_distancia = 10  # Ajusta según separación mínima esperada
umbral_distancia = 20  # Ajusta según el valor mínimo aceptable en el mapa de distancia

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
        ((x, y), r) = cv2.minEnclosingCircle(c)

        # FILTRADO MEJORADO
        radio_mascara_efectivo = radio_mascara - erosion_px
        margen_borde = max(int(0.06 * radio_mascara_efectivo), 12)

        distancia_al_centro = np.sqrt((x - centro[0])**2 + (y - centro[1])**2)

        # filtros por área mínima y circularidad
        min_area = max(40, int(np.pi * (2.5**2)))
        perim = cv2.arcLength(c, True)
        circularity = 0
        if perim > 0:
            circularity = 4 * np.pi * area / (perim * perim)

        borde_tol = max(5, int(0.02 * radio_mascara))

        # 1) Reemplazo: calcular solapamiento con la franja en lugar de excluir por cualquier toque
        area_contour_px = np.count_nonzero(mask > 0)
        if area_contour_px == 0:
            continue
        area_overlap_px = np.count_nonzero(np.logical_and(mask_edge > 0, mask > 0))
        overlap_ratio = (area_overlap_px / area_contour_px)

        # Área dentro de la máscara original y dentro de la máscara erosionada
        area_inside_original = np.count_nonzero(np.logical_and(mask_circular > 0, mask > 0))
        area_inside_eroded = np.count_nonzero(np.logical_and(mask_circular_eroded > 0, mask > 0))
        frac_inside_original = area_inside_original / area_contour_px
        frac_inside_eroded = area_inside_eroded / area_contour_px

        # Si el contorno está completamente fuera de la máscara circular original, descartar
        if area_inside_original == 0:
            continue

        # Umbrales ajustables: permitir mayor solapamiento si suficiente parte queda dentro
        overlap_threshold = 0.55     # si overlap_ratio > threshold normalmente descartamos
        min_frac_inside_original = 0.20  # si >= 65% del contorno está dentro de la máscara original, permitimos
        min_frac_inside_eroded = 0.55    # si >= 35% queda dentro de la máscara erosionada lo aceptamos

        # Si solapa mucho pero está mayormente dentro de la máscara original, aceptarlo
        if overlap_ratio > overlap_threshold and not (frac_inside_original >= min_frac_inside_original or frac_inside_eroded >= min_frac_inside_eroded):
            continue

        # 2) Geometría: permitir si parte significativa del contorno queda dentro del radio efectivo
        #    Comprobar que al menos una fracción (p.ej. 40%) del contorno está dentro de la máscara erosionada
        if frac_inside_eroded < min_frac_inside_eroded:
            # como excepción, si el centro geométrico del objeto está bien dentro, permitir
            M = cv2.moments(c)
            if M["m00"] != 0:
                cx = int(M["m10"] / M["m00"])
                cy = int(M["m01"] / M["m00"])
                if mask_circular_eroded[cy, cx] == 0:
                    continue
            else:
                continue

        # 3) Comprobaciones adicionales de área y circularidad estaba en .1
        if area < max(20, min_area) or circularity < 0.05:
            continue

        # Si pasa todos los filtros, contar
        contador_colonias += 1
        # Ajustar radio de dibujo para no pintar sobre el aro externo
        orig_r = max(1, int(round(r)))
        # reducción base (evita solapado visual con el borde)
        draw_r = max(1, orig_r - 3)
        # si hay solapamiento con la franja, reducir proporcionalmente más
        if overlap_ratio > 0.05:
            extra_reduc = int(min(orig_r * 0.6, max(2, overlap_ratio * orig_r * 2)))
            draw_r = max(1, orig_r - extra_reduc)

        # Dibujar con radio reducido y grosor menor para evitar "tocar" el borde
        cv2.circle(image_resultado, (int(x), int(y)), draw_r, (255, 255, 255), 4)
        # Posicionar la etiqueta ligeramente hacia el centro para que no salga fuera
        txt_x = int(x) - min(10, draw_r)
        txt_y = int(y)
        cv2.putText(image_resultado, f"#{label}", (txt_x, txt_y),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 8)

print(f"[INFO] {contador_colonias} colonias detectadas")

# Mostrar con Matplotlib
plt.figure(figsize=(14, 7))
plt.subplot(2, 4, 1)
plt.imshow(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
plt.title("Imagen original")
plt.axis("off")

# plt.subplot(2, 4, 2)
# plt.imshow(cv2.cvtColor(imagen_suavizada, cv2.COLOR_BGR2RGB))
# plt.title("imagen suavizada")
# plt.axis("off")

# plt.subplot(2, 4, 3)
# plt.imshow(gray, cmap="gray")
# plt.title("Gris")
# plt.axis("off")



# plt.subplot(2, 4, 4)
# plt.imshow(thresh, cmap="gray")
# plt.title("Umbral Otsu invertido")
# plt.axis("off")

# plt.subplot(2, 4,5)
# plt.imshow(mask_circular, cmap="gray")
# plt.title("Mascara circular")
# plt.axis("off")

# plt.subplot(2, 4, 6)
# plt.imshow(D, cmap="jet")
# plt.title("Mapa de distancia")
# plt.axis("off")

plt.subplot(2, 4, 2)
# plt.imshow(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
plt.imshow(cv2.cvtColor(image_resultado, cv2.COLOR_BGR2RGB))
plt.title("Colonias detectadas")
plt.axis("off")

plt.tight_layout()
plt.show()

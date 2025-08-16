import cv2
import numpy as np
import matplotlib.pyplot as plt

# Inicializar el objeto BackgroundSubtractor
backSub = cv2.createBackgroundSubtractorMOG2()

# Capturar video o leer imagen
#cap = cv2.VideoCapture('video.mp4')  # Para video
#while(1):
#    ret, frame = cap.read()
#    if not ret:
#        break
frame = cv2.imread('test.jpg') # Para imagen
    
# Convertir a escala de grises (opcional, pero recomendado para MOG2)
#gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

# Aplicar la sustracción de fondo
fgMask = backSub.apply(frame)

# Filtrar la máscara (opcional)
kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
fgMask = cv2.morphologyEx(fgMask, cv2.MORPH_OPEN, kernel)


# Aplicar la máscara a la imagen original
#result = cv2.bitwise_and(frame, frame, mask=fgMask)
result = cv2.bitwise_and(frame, frame, mask=fgMask)
# Mostrar resultados
cv2.imshow('Frame', frame)
cv2.imshow('FG Mask', fgMask)
cv2.imshow('Result', result)

# Esperar a que se presione una tecla y cerrar ventanas
#cv2.waitKey(0) # Si es una imagen
#cap.release() # Si es un video
cv2.destroyAllWindows()
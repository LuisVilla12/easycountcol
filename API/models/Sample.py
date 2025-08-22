from pydantic import BaseModel
from datetime import date
from datetime import datetime
from passlib.context import CryptContext
from db import get_db
from fastapi import HTTPException, UploadFile
from PIL import Image  # <-- ¡IMPORTANTE! necesitas importar PILLOW
import shutil
import os
import uuid
# import time
import cv2
# import numpy as np
from ia.algoritmo_water import tratamiento_imagen


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class RegistarMuestra(BaseModel):
    sampleName: str
    idUser: int
    typeSample: str
    volumenSample: str
    factorSample: str
    sampleRoute: str
    processingTime: float
    count: int
    creationDate: date
    creationTime: str
    medioSample: str

    @classmethod
    def save_with_file(cls, sampleName: str, idUser: int, typeSample: str,volumenSample: str,factorSample: str,sample_file: UploadFile, medioSample: str = "N/A"):
        try:
            #Verificar existencia de las carpetas donde esta almacenada las imagenes
            os.makedirs("uploads", exist_ok=True)
            os.makedirs("processed", exist_ok=True)
            
            # Asignar un nombre unico
            filename = f"{uuid.uuid4().hex}_{sample_file.filename}"
            file_location = f"uploads/{filename}"
            # Reinicia el puntero del archivo al primer
            sample_file.file.seek(0) 
            
            # Reiniciar lectura del archivo
            with open(file_location, "wb") as buffer:
                # Guarda el archivo subidoa la carpeta uploads
                shutil.copyfileobj(sample_file.file, buffer)

            # Crear la ruta para guardar la imagen procesada
            processed_location = f"processed/{filename}"
            
            
            resultado = tratamiento_imagen(file_location)
            image_resultado = resultado["image_resultado"]
            
            labels = resultado["labels"]
            # processing_time = resultado["processing_time_str"]
            
            # Guardar imagen procesada
            cv2.imwrite(processed_location, image_resultado)


            # Guardar la imagen procesada
            # with Image.open(file_location) as image:
            #     image.save(processed_location)
            

            # Determinar la hora
            ahoraActual = datetime.now()
            creation_time = ahoraActual.strftime("%H:%M:%S")
            
            # Crear la instancia de RegistarMuestra
            muestra = cls(
                sampleName=sampleName,
                idUser=idUser,
                typeSample=typeSample,
                volumenSample=volumenSample,
                factorSample=factorSample,
                sampleRoute=filename,
                count=labels,
                processingTime=0,
                creationDate=date.today(),
                creationTime=creation_time,
                medioSample=medioSample,
            )

            # 4. Guardar en la base de datos
            conn = get_db()
            cursor = conn.cursor()

            sql = """
                INSERT INTO samples (
                    sampleName, idUser, typeSample, volumenSample,
                    factorSample, sampleRoute, creationDate,processingTime,count,creationTime, medioSample
                ) 
                VALUES (%s, %s, %s, %s, %s, %s, %s,%s,%s,%s,%s)
            """
            cursor.execute(sql, (
                muestra.sampleName,
                muestra.idUser,
                muestra.typeSample,
                muestra.volumenSample,
                muestra.factorSample,
                muestra.sampleRoute,
                muestra.creationDate,
                muestra.processingTime,
                muestra.count,
                muestra.creationTime,
                muestra.medioSample
            ))
            sample_id = cursor.lastrowid

            conn.commit()
            cursor.close()
            conn.close()

            # Regresar el id de la muestra y mensaje
            return {
                "success": True,
                "idSample": sample_id,
                "message": "Muestra registrada correctamente."
            }
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Error al registrar muestra: {e}")

    def update_sample(cls,idSample:int, sampleName: str, idUser: int, typeSample: str,volumenSample: str,factorSample: str, medioSample: str, count:str,processingTime:str,date:str,creationTime:str):
        try:
            muestra = cls(
                sampleName=sampleName,
                idUser=idUser,
                typeSample=typeSample,
                volumenSample=volumenSample,
                factorSample=factorSample,
                count=count,
                processingTime=processingTime,
                creationDate=date,
                creationTime=creationTime,
                medioSample=medioSample,
            )
            conn = get_db()
            cursor = conn.cursor()

            sql = """
                INSERT INTO samples (
                    sampleName, idUser, typeSample, volumenSample,
                    factorSample, sampleRoute, creationDate,processingTime,count,creationTime, medioSample
                ) 
                VALUES (%s, %s, %s, %s, %s, %s, %s,%s,%s,%s,%s)
            """
            cursor.execute(sql, (
                muestra.sampleName,
                muestra.idUser,
                muestra.typeSample,
                muestra.volumenSample,
                muestra.factorSample,
                muestra.sampleRoute,
                muestra.creationDate,
                muestra.processingTime,
                muestra.count,
                muestra.creationTime,
                muestra.medioSample
            ))
            sample_id = cursor.lastrowid

            conn.commit()
            cursor.close()
            conn.close()

            # Regresar el id de la muestra y mensaje
            return {
                "success": True,
                "idSample": sample_id,
                "message": "Muestra actualizada correctamente."
            }
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Error al registrar muestra: {e}")
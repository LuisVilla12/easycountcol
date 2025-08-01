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
import time

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
            sample_file.file.seek(0) 
            # Reiniciar lectura del archivo
            with open(file_location, "wb") as buffer:
                shutil.copyfileobj(sample_file.file, buffer)
            # Inicio de tiempo para procesamiento a escala de grises
            start_time = time.time()  
            # Crear y guardar la imagen en escala de grises
            processed_location = f"processed/{filename}"
            with Image.open(file_location) as image:
                image = image.convert("L")  # Convertir a escala de grises
                image.save(processed_location)
            #Fin del tiempo para la escala de grises
            end_time = time.time()  
            # Resta del tiempo de fin y el inicio
            processing_time = end_time - start_time 
            # Conteo de UFC
            count=5
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
                count=count,
                processingTime=processing_time,
                creationDate=date.today(),
                creationTime=creation_time,
                medioSample=medioSample,
            )
            # print(f"Registro de muestra: {muestra}")
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
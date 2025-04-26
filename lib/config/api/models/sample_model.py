from pydantic import BaseModel
from datetime import date
from db import get_db
from fastapi import HTTPException, UploadFile
import shutil
import os
import uuid
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class RegistarMuestraA(BaseModel):
    sample_name: str
    id_user: int
    type_sample: str
    volumen_sample: str
    factor_sample: str
    sample_route: str
    creation_date: date

    @classmethod
    def save_with_file(cls, 
                       sample_name: str, 
                       id_user: int, 
                       type_sample: str,
                       volumen_sample: str,
                       factor_sample: str,
                       sample_file: UploadFile):
        try:
            # 1. Guardar el archivo
            os.makedirs("uploads", exist_ok=True)

            filename = f"{uuid.uuid4().hex}_{sample_file.filename}"
            file_location = f"uploads/{filename}"

            sample_file.file.seek(0)  # Reiniciar lectura del archivo

            with open(file_location, "wb") as buffer:
                shutil.copyfileobj(sample_file.file, buffer)

            # 2. Crear la instancia de RegistarMuestraA
            muestra = cls(
                sample_name=sample_name,
                id_user=id_user,
                type_sample=type_sample,
                volumen_sample=volumen_sample,
                factor_sample=factor_sample,
                sample_route=file_location,
                creation_date=date.today()
            )

            # 3. Guardar en la base de datos
            conn = get_db()
            cursor = conn.cursor()

            sql = """
                INSERT INTO samples (
                    sample_name, id_user, type_sample, volumen_sample,
                    factor_sample, sample_route, creation_date
                ) 
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (
                muestra.sample_name,
                muestra.id_user,
                muestra.type_sample,
                muestra.volumen_sample,
                muestra.factor_sample,
                muestra.sample_route,
                muestra.creation_date
            ))
            conn.commit()

            cursor.close()
            conn.close()

            return {"success": True, "message": "Muestra registrada correctamente."}

        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Error al registrar muestra: {e}")

from pydantic import BaseModel
from datetime import date
from db import get_db
from fastapi import HTTPException
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

def registar_muestra(data: RegistarMuestraA):
    try:
        fecha_actual = date.today()
        conn = get_db()
        cursor = conn.cursor()

        sql = """
            INSERT INTO samples (sample_name,id_user, type_sample, volumen_sample, factor_sample, sample_route,creation_date)
            VALUES (%s, %s, %s, %s, %s,%s,%s)
        """
        cursor.execute(sql, (data.sample_name, 1, data.type_sample, data.volumen_sample, data.factor_sample,data.sample_route,data.creation_date))
        conn.commit()

        cursor.close()
        conn.close()

        return {"success": True, "message": "Usuario registrado correctamente."}

    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error al registrar: {e}")

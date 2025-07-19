#Importa la clase FastAPI para crear la aplicación.
from fastapi import FastAPI, HTTPException,Form,File,UploadFile
from fastapi.responses import JSONResponse
# Importa los modelos a utilizar
from models.user_model import RegistroUsuario, registrar_usuario
from models.login_model import LoginUsuario, login_usuario 
from models.sample_model import RegistarMuestraA 
from fastapi.responses import FileResponse
import shutil
import os
from db import get_db

#Crea una instancia de la aplicación FastAPI.
app = FastAPI()
#Define una ruta raíz
@app.get("/")
def home():
    return {"mensaje": "Bienvenido a la API"}
#Ruta para el registro de un usuario
@app.post("/registro")
def registrar(data: RegistroUsuario):
    try:
        registrar_usuario(data)
        return {"mensaje": "Usuario registrado con éxito"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
#Ruta para inicio de sesión
@app.post("/login")
def login(usuario: LoginUsuario):
    return login_usuario(usuario)
#Ruta para registro de una muestra
@app.post("/registrar-muestra-file")
async def registrar_muestra_file(
    sample_name: str = Form(...),
    id_user: int = Form(...),
    type_sample: str = Form(...),
    volumen_sample: str = Form(...),
    factor_sample: str = Form(...),
    sample_file: UploadFile = File(...)):
    return RegistarMuestraA.save_with_file(
        sample_name=sample_name,
        id_user=id_user,
        type_sample=type_sample,
        volumen_sample=volumen_sample,
        factor_sample=factor_sample,
        sample_file=sample_file
    )
#Ruta para mostar la imagen procesada
@app.get("/imagen-procesada/{id_muestra}")
def get_processed_image(id_muestra: int):
    try:
        conn = get_db()
        cursor = conn.cursor()

        sql = "SELECT sample_route FROM samples WHERE id_sample = %s"
        cursor.execute(sql, (id_muestra,))
        result = cursor.fetchone()

        cursor.close()
        conn.close()

        if not result:
            raise HTTPException(status_code=404, detail="Muestra no encontrada")

        filename = result[0]
        processed_path = f"processed/{filename}"

        if not os.path.exists(processed_path):
            raise HTTPException(status_code=404, detail="Imagen procesada no encontrada")

        return FileResponse(processed_path, media_type="image/png")

    except Exception as e:
        print(f"ERROR AL CARGAR IMAGEN procesada: {e}") 
        raise HTTPException(status_code=400, detail=f"Error al cargar imagen procesada: {e}")
#Ruta para mostar la imagen original
@app.get("/imagen-original/{id_muestra}")
def get_original_image(id_muestra: int):
    try:
        conn = get_db()
        cursor = conn.cursor()

        sql = "SELECT sample_route FROM samples WHERE id_sample = %s"
        cursor.execute(sql, (id_muestra,))
        result = cursor.fetchone()

        cursor.close()
        conn.close()

        if not result:
            raise HTTPException(status_code=404, detail="Muestra no encontrada")

        filename = result[0]
        original_path = f"uploads/{filename}"  # Asegúrate de que el archivo está en esta ruta

        if not os.path.exists(original_path):
            raise HTTPException(status_code=404, detail="Imagen original no encontrada")

        return FileResponse(original_path, media_type="image/png")

    except Exception as e:
        print(f"ERROR AL CARGAR IMAGEN ORIGINAL: {e}")  # <-- log
        raise HTTPException(status_code=400, detail=f"Error al cargar imagen original: {e}")

#Ruta para mostar la informacion de la muestra
@app.get("/muestra-info/{id_muestra}")
def get_sample_info(id_muestra: int):
    conn = get_db()
    cursor = conn.cursor()
    sql = "SELECT * FROM samples WHERE id_sample = %s"
    cursor.execute(sql, (id_muestra,))
    result = cursor.fetchall()
    cursor.close()
    conn.close()

    if not result:
        raise HTTPException(status_code=404, detail="Muestra no encontrada")
    
    return {"sample": result[0]}

#Ruta para mostar todas las muestras
@app.get("/samples")
def getSamples():
    conn = get_db()
    cursor = conn.cursor()
    sql = "SELECT * FROM samples"
    cursor.execute(sql)
    result = cursor.fetchall()
    cursor.close()
    conn.close()

    if not result:
        raise HTTPException(status_code=404, detail="Muestras no encontradas")
    
    return {"samples": result}

#Ruta para mostar las muestras de un usuario
@app.get("/samples/{id_user}")
def getSamplesUser(id_user: int):
    try:
        conn = get_db()
        cursor = conn.cursor()

        sql = "SELECT * FROM samples WHERE id_user = %s"
        cursor.execute(sql, (id_user,))
        result = cursor.fetchall()
        cursor.close()
        conn.close()
        # if not result:
        #     raise HTTPException(status_code=404, detail="No cuenta con muestras")
        
        return {"samples": result}

    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Eror: {e}") 

@app.get("/ping")
async def ping():
    return JSONResponse(content={"status": "ok"})
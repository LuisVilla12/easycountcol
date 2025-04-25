from fastapi import FastAPI, HTTPException,Form,File,UploadFile
from models.user_model import RegistroUsuario, registrar_usuario
from models.login_model import LoginUsuario, login_usuario 
from models.sample_model import RegistarMuestraA, registar_muestra 
import uuid
import shutil


app = FastAPI()

@app.get("/")
def home():
    return {"mensaje": "Bienvenido a la API"}


@app.post("/registro")
def registrar(data: RegistroUsuario):
    try:
        registrar_usuario(data)
        return {"mensaje": "Usuario registrado con éxito"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/login")
def login(usuario: LoginUsuario):
    return login_usuario(usuario)

@app.post("/registrar-muestra-file")    
async def registrar_muestra_file(
    sample_name: str = Form(...),
    id_user: int = Form(...),
    type_sample: str = Form(...),
    volumen_sample: str = Form(...),
    factor_sample: str = Form(...),
    sample_file: UploadFile = File(...)
):
    try:
        import os
        import shutil
        from datetime import date

        # Asegura que la carpeta exista
        os.makedirs("uploads", exist_ok=True)

        # Nombre único para evitar colisiones
        filename = f"{uuid.uuid4().hex}_{sample_file.filename}"
        file_location = f"uploads/{filename}"

        # Importante: Reiniciar puntero del archivo
        sample_file.file.seek(0)

        # Guardar archivo
        with open(file_location, "wb") as buffer:
            shutil.copyfileobj(sample_file.file, buffer)

        # Guardar en base de datos
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
            sample_name,
            id_user,
            type_sample,
            volumen_sample,
            factor_sample,
            file_location,
            date.today()
        ))
        print("✅ Insert ejecutado, haciendo commit...")
        conn.commit()
        cursor.close()
        conn.close()

        return {"success": True, "message": "Muestra registrada con archivo"}

    except Exception as e:
        return {"success": False, "error": str(e)}
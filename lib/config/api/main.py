from fastapi import FastAPI, HTTPException,Form,File,UploadFile
from models.user_model import RegistroUsuario, registrar_usuario
from models.login_model import LoginUsuario, login_usuario 
from models.sample_model import RegistarMuestraA 
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
    return RegistarMuestraA.save_with_file(
        sample_name=sample_name,
        id_user=id_user,
        type_sample=type_sample,
        volumen_sample=volumen_sample,
        factor_sample=factor_sample,
        sample_file=sample_file
    )

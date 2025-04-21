from fastapi import FastAPI, HTTPException
from models import RegistroUsuario, registrar_usuario

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

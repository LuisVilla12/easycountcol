from fastapi import FastAPI, HTTPException
from models.user_model import RegistroUsuario, registrar_usuario
from models.login_model import LoginUsuario, login_usuario 

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
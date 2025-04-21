from pydantic import BaseModel, EmailStr
from db import get_db
from passlib.context import CryptContext


class RegistroUsuario(BaseModel):
    name: str
    lastname: str
    username: str
    email: EmailStr
    password: str

def registrar_usuario(data: RegistroUsuario):
    conn = get_db()
    cursor = conn.cursor()

    sql = """
        INSERT INTO users (name,lastname,username, email, password)
        VALUES (%s,%s,%s, %s, %s)
    """
    cursor.execute(sql, (data.name,data.lastname,data.username, data.email, data.password))
    conn.commit()

    cursor.close()
    conn.close()

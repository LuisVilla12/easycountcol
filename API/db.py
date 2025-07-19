import mysql.connector

def get_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="lkqaz923",
        database="easycountcol",
        port=3307,
        charset='utf8mb4',
        collation='utf8mb4_general_ci'
    )

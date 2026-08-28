import json
from pathlib import Path
from urllib.parse import quote_plus

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker


SECRET_PATH = Path("/run/secrets/backend-db-secret.json")


def load_database_credentials():
    if not SECRET_PATH.exists():
        raise RuntimeError(
            f"Database secret file not found: {SECRET_PATH}"
        )

    with SECRET_PATH.open() as file:
        return json.load(file)


credentials = load_database_credentials()

username = quote_plus(credentials["username"])
password = quote_plus(credentials["password"])
host = credentials["host"]
port = credentials["port"]
database = credentials["dbname"]

DATABASE_URL = (
    f"postgresql+psycopg://{username}:{password}"
    f"@{host}:{port}/{database}"
)

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
)

SessionLocal = sessionmaker(
    bind=engine,
    autoflush=False,
    autocommit=False,
)


def check_database():
    with engine.connect() as connection:
        connection.execute(text("SELECT 1"))

    return True
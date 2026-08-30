from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import check_database


app = FastAPI(title="DevOps Practice API")


app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:8080",
        "http://127.0.0.1:8080",
        "https://orema-devops.xyz",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {
        "message": "Backend is running"
    }


@app.get("/api/message")
def get_message():
    return {
        "message": "Hello from the Python FastAPI backend!"
    }


@app.get("/api/health")
def health_check():
    return {
        "status": "unhealthy"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


@app.get("/api/db-health")
def database_health():
    check_database()

    return {
        "status": "healthy",
        "database": "connected"
    }
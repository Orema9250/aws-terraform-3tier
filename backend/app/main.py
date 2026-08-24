from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
##########################################################################
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

###to get the  health check
@app.get("/api/health")
def health_check():
    return {
        "status": "healthy"
    }

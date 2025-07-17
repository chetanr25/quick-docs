"""
FastAPI main application entry point
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn

from app.api.v1.api import api_router
from app.core.config import settings
from app.core.exceptions import AppException, app_exception_handler

def create_application() -> FastAPI:
    """Create and configure FastAPI application"""
    
    app = FastAPI(
        title=settings.PROJECT_NAME,
        version=settings.VERSION,
        description="Quick Docs - File text extraction and uploading to cloud",
        openapi_url=f"{settings.API_V1_STR}/openapi.json"
    )

    if settings.ALLOWED_HOSTS:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=[str(origin) for origin in settings.ALLOWED_HOSTS],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

    app.add_exception_handler(AppException, app_exception_handler)

    app.include_router(api_router, prefix=settings.API_V1_STR)

    @app.get("/")
    async def root():
        return {"message": "Quick Docs API", "version": settings.VERSION}
    
    @app.get("/health")
    async def health_check():
        return JSONResponse(content={"status": "ok"}, status_code=200)

    return app

app = create_application()

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )

"""
Main API router
"""
from fastapi import APIRouter
from app.api.v1.endpoints import files

api_router = APIRouter()

api_router.include_router(files.router, prefix="/files", tags=["files"])
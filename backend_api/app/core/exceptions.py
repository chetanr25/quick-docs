"""
Custom exception classes and handlers
"""
from fastapi import Request
from fastapi.responses import JSONResponse
from typing import Any

class AppException(Exception):
    """Base application exception"""
    def __init__(self, message: str, status_code: int = 500):
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)

class FileProcessingException(AppException):
    """Exception raised during file processing"""
    def __init__(self, message: str = "File processing failed"):
        super().__init__(message, 422)

class StorageException(AppException):
    """Exception raised during storage operations"""
    def __init__(self, message: str = "Storage operation failed"):
        super().__init__(message, 500)

class ValidationException(AppException):
    """Exception raised during validation"""
    def __init__(self, message: str = "Validation failed"):
        super().__init__(message, 400)

async def app_exception_handler(request: Request, exc: AppException) -> JSONResponse:
    """Handle application exceptions"""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": True,
            "message": exc.message,
            "status_code": exc.status_code
        }
    )

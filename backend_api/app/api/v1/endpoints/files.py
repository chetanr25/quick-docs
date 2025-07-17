"""
File upload and processing API endpoints
"""
import uuid
import time
from datetime import datetime
from fastapi import APIRouter, Form, UploadFile, File, HTTPException

from app.models.schemas import (
    FileProcessingResult, 
)
from app.services.storage import storage_service
from app.services.file_processing import file_processing_service
from app.services.nlp import nlp_service

from app.core.config import settings
from app.core.exceptions import FileProcessingException, StorageException, ValidationException
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

@router.post("/upload-sync", response_model=FileProcessingResult)
async def upload_file_sync(
    file: UploadFile = File(...),
    email: str = Form(default="")
):
    """
    Upload and process a file synchronously (for smaller files)
    
    - file: File to upload and process
    - email: Optional email address
    
    Returns complete processing result immediately
    """
    try:
        if not file.filename:
            raise ValidationException("No file provided")
        
        file_extension = '.' + file.filename.split('.')[-1].lower() if '.' in file.filename else ''
        if file_extension not in settings.ALLOWED_FILE_TYPES:
            raise ValidationException(f"File type {file_extension} not supported")
        
        file_content = await file.read()
        
        sync_max_size = 1000 * 1024 * 1024  # 1GB for sync
        if len(file_content) > sync_max_size:
            raise ValidationException(f"File too large for synchronous processing. Use async upload endpoint.")
        
        start_time = time.time()
        
        blob_name, blob_url = await storage_service.upload_file(
            file_content, file.filename, file.content_type or "application/octet-stream",email=email
        )
        
        text_result = await file_processing_service.extract_text(
            file_content, file.content_type or "application/octet-stream", file.filename
        )
        
        tokenization_result = await nlp_service.tokenize_text(
            text_result.extracted_text, file.filename
        )
        
        return FileProcessingResult(
            file_id=blob_name,
            file_url=blob_url,
            filename=file.filename,
            file_size=len(file_content),
            content_type=file.content_type,
            text_extraction=text_result,
            tokenization=tokenization_result,
            processing_time=time.time() - start_time,
            timestamp=datetime.now()
        )
        
    except ValidationException as e:
        raise HTTPException(status_code=400, detail=str(e))
    except (FileProcessingException, StorageException) as e:
        raise HTTPException(status_code=422, detail=str(e))
    except Exception as e:
        logger.error(f"Sync upload failed: {e}")
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")

@router.delete("/delete/{file_id}")
async def delete_file(file_id: str):
    """
    Delete a file from Azure Storage
    
    - **file_id**: ID of the file to delete (blob name)
    """
    try:
        success = await storage_service.delete_file(file_id)
        if success:
            return {"message": "File deleted successfully"}
        else:
            raise HTTPException(status_code=404, detail="File not found")
    except Exception as e:
        logger.error(f"Delete failed: {e}")
        raise HTTPException(status_code=500, detail=f"Delete failed: {str(e)}")

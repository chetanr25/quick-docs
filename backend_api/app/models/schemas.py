"""
Data models and schemas
"""
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class FileUploadResponse(BaseModel):
    """Response model for file upl§oad"""
    success: bool
    message: str
    file_url: Optional[str] = None
    file_id: Optional[str] = None
    processing_id: Optional[str] = None

class TextExtractionResult(BaseModel):
    """Model for text extraction results"""
    extracted_text: str
    text_length: int
    extraction_method: str

class TokenizationResult(BaseModel):
    """Model for tokenization results"""
    tokens: List[str]
    token_count: int
    unique_tokens: int
    method: str = "spacy"

class FileProcessingResult(BaseModel):
    """Complete file processing result"""
    file_id: str
    file_url: str
    filename: str
    file_size: int
    content_type: str
    text_extraction: TextExtractionResult
    tokenization: TokenizationResult
    processing_time: float
    timestamp: datetime

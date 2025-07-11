"""
File processing service for text extraction
"""
import os
import tempfile
import PyPDF2
import docx
from app.core.config import settings
from app.core.exceptions import FileProcessingException
from app.models.schemas import TextExtractionResult
import logging

logger = logging.getLogger(__name__)

class FileProcessingService:
    """Service for extracting text from various file types"""
    
    def __init__(self):
        self.supported_types = {
            'application/pdf': self._extract_pdf_text,
            'text/plain': self._extract_txt_text,
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document': self._extract_docx_text,
        }
    
    async def extract_text(self, file_content: bytes, content_type: str, filename: str) -> TextExtractionResult:
        """
        Extract text from file content
        
        Args:
            file_content: File content as bytes
            content_type: MIME type of the file
            filename: Original filename
        
        Returns:
            TextExtractionResult with extracted text and metadata
        """
        if content_type not in self.supported_types:
            raise FileProcessingException(f"Unsupported file type: {content_type}")
        
        try:
            with tempfile.NamedTemporaryFile(delete=False, suffix=self._get_file_extension(filename)) as temp_file:
                temp_file.write(file_content)
                temp_file_path = temp_file.name
            
            try:
                extracted_text = await self.supported_types[content_type](temp_file_path)
                
                return TextExtractionResult(
                    extracted_text=extracted_text,
                    text_length=len(extracted_text),
                    extraction_method=self._get_extraction_method(content_type)
                )
            finally:
                if os.path.exists(temp_file_path):
                    os.unlink(temp_file_path)
                    
        except Exception as e:
            logger.error(f"Text extraction failed for {filename}: {e}")
            raise FileProcessingException(f"Text extraction failed: {str(e)}")
    
    def _get_file_extension(self, filename: str) -> str:
        """Get file extension from filename"""
        return '.' + filename.split('.')[-1] if '.' in filename else ''
    
    def _get_extraction_method(self, content_type: str) -> str:
        """Get extraction method name from content type"""
        method_map = {
            'application/pdf': 'PyPDF2',
            'text/plain': 'direct',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document': 'python-docx',
            'application/msword': 'python-docx',
        }
        return method_map.get(content_type, 'unknown')
    
    async def _extract_pdf_text(self, file_path: str) -> str:
        """Extract text from PDF file"""
        try:
            text = ""
            with open(file_path, 'rb') as file:
                pdf_reader = PyPDF2.PdfReader(file)
                for page in pdf_reader.pages:
                    text += page.extract_text() + "\n"
            return text.strip()
        except Exception as e:
            raise FileProcessingException(f"PDF text extraction failed: {str(e)}")
    
    async def _extract_txt_text(self, file_path: str) -> str:
        """Extract text from TXT file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                return file.read()
        except Exception as e:
            raise FileProcessingException(f"TXT text extraction failed: {str(e)}")
    
    async def _extract_docx_text(self, file_path: str) -> str:
        """Extract text from DOCX file"""
        try:
            doc = docx.Document(file_path)
            text = ""
            for paragraph in doc.paragraphs:
                text += paragraph.text + "\n"
            return text.strip()
        except Exception as e:
            raise FileProcessingException(f"DOCX text extraction failed: {str(e)}")
    
file_processing_service = FileProcessingService()

"""
Azure Blob Storage service
"""
import uuid
from typing import Optional, Tuple
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient, ContentSettings
from app.core.config import settings
from app.core.exceptions import StorageException
import logging

logger = logging.getLogger(__name__)

class AzureStorageService:
    """Service for handling Azure Blob Storage operations"""
    
    def __init__(self):
        try:
            default_credential = DefaultAzureCredential()
            self.blob_service_client = BlobServiceClient(settings.AZURE_STORAGE_ACCOUNT_URL,credential=default_credential)
            
            self._ensure_container_exists()
        except Exception as e:
            logger.error(f"Failed to initialize Azure Storage Service: {e}")
            logger.warning("Falling back to mock storage for development.")
            self.blob_service_client = None
    
    def _ensure_container_exists(self):
        """Ensure the container exists"""
        if not self.blob_service_client:
            return
            
        try:
            container_client = self.blob_service_client.get_container_client(settings.AZURE_STORAGE_CONTAINER_NAME)
            if not container_client.exists():
                container_client.create_container()
                logger.info(f"Created container: {self.container_name}")
        except Exception as e:
            logger.error(f"Failed to ensure container exists: {e}")
            raise StorageException(f"Container setup failed: {str(e)}")
    
    async def upload_file(
        self, 
        file_content: bytes, 
        filename: str, 
        content_type: str,
        email: Optional[str] = None
    ) -> Tuple[str, str]:
        # return "",""
        """
        Upload file to Azure Blob Storage
        
        Args:
            file_content: File content as bytes
            filename: Original filename
            content_type: MIME type of the file
        
        Returns:
            Tuple of (blob_name, blob_url)
        """
        try:
            file_extension = filename.split('.')[-1] if '.' in filename else ''
            blob_name = f"{email}_{uuid.uuid4()}.{file_extension}" if file_extension else str(uuid.uuid4())
            
            if not self.blob_service_client:
                blob_url = settings.AZURE_STORAGE_ACCOUNT_URL + f"/{settings.AZURE_STORAGE_CONTAINER_NAME}/{blob_name}"
                logger.info(f"Mock upload: {blob_name}")
                return blob_name, blob_url
            
            blob_client = self.blob_service_client.get_blob_client(
                container=settings.AZURE_STORAGE_CONTAINER_NAME, 
                blob=blob_name
            )
            
            content_settings = ContentSettings(content_type=content_type)
            
            blob_client.upload_blob(
                file_content, 
                overwrite=True,
                content_settings=content_settings
            )
            
            blob_url = blob_client.url
            logger.debug(blob_url)
            logger.info(f"Successfully uploaded file: {blob_name}")
            return blob_name, blob_url
            
        except Exception as e:
            logger.error(f"Failed to upload file: {e}")
            raise StorageException(f"File upload failed: {str(e)}")
    
    async def delete_file(self, blob_name: str) -> bool:
        """
        Delete file from Azure Blob Storage
        
        Args:
            blob_name: Name of the blob to delete
        
        Returns:
            True if successful, False otherwise
        """
        try:
            blob_client = self.blob_service_client.get_blob_client(
                container=settings.AZURE_STORAGE_CONTAINER_NAME, 
                blob=blob_name
            )
            
            blob_client.delete_blob()
            logger.info(f"Successfully deleted file: {blob_name}")
            return True
        except Exception as e:
            logger.error(f"Failed to delete file {blob_name}: {e}")
            return False
    
    async def get_file_url(self, blob_name: str) -> Optional[str]:
        """
        Get URL for a blob
        
        Args:
            blob_name: Name of the blob
        
        Returns:
            Blob URL or None if not found
        """
        try:
            blob_client = self.blob_service_client.get_blob_client(
                container=settings.AZURE_STORAGE_CONTAINER_NAME, 
                blob=blob_name
            )
            if blob_client.exists():
                return blob_client.url
            return None
        except Exception as e:
            logger.error(f"Failed to get file URL for {blob_name}: {e}")
            return None

storage_service = AzureStorageService()

"""
Simple application configuration settings
"""
import os
from typing import List
from dotenv import load_dotenv

load_dotenv()

class Settings:
    # API Settings
    PROJECT_NAME: str = "Quick Docs API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    ALLOWED_HOSTS: List[str] = []
    
    # Azure Storage Settings
    AZURE_STORAGE_CONNECTION_STRING: str = os.getenv("AZURE_STORAGE_CONNECTION_STRING", "")
    AZURE_STORAGE_CONTAINER_NAME: str = os.getenv("AZURE_STORAGE_CONTAINER_NAME", "quickdocs")
    AZURE_STORAGE_ACCOUNT_URL: str = os.getenv("AZURE_STORAGE_ACCOUNT_URL", "")
    
    AZURE_STORAGE_ACCOUNT_URL: str = os.getenv("AZURE_STORAGE_ACCOUNT_URL",)
    
    MAX_FILE_SIZE: int = int(os.getenv("MAX_FILE_SIZE", "52428800"))
    ALLOWED_FILE_TYPES: List[str] = [".pdf", ".txt", ".docx", ".doc"]
    
    # NLP Settings
    NLP_MODEL: str = os.getenv("NLP_MODEL", "en_core_web_sm") # Skipping for now, using basic tokenization due to high resource requirements and latency
    
    # Backend URL
    BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:8000")
    
    def __init__(self):
        allowed_hosts_str = os.getenv("ALLOWED_HOSTS", "")
        if allowed_hosts_str:
            self.ALLOWED_HOSTS = [host.strip() for host in allowed_hosts_str.split(",")]
        
        # Validate critical Azure settings in production
        if not self.AZURE_STORAGE_ACCOUNT_URL:
            print("WARNING: AZURE_STORAGE_ACCOUNT_URL not set - Azure Storage will not work!")
        
        if not self.AZURE_STORAGE_CONTAINER_NAME:
            print("WARNING: AZURE_STORAGE_CONTAINER_NAME not set - using default 'quickdocs'")
            self.AZURE_STORAGE_CONTAINER_NAME = "quickdocs"

settings = Settings()
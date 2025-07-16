"""
NLP service for text tokenization and analysis
"""
import re
from typing import List, Set
from collections import Counter
from app.core.config import settings
from app.core.exceptions import FileProcessingException
from app.models.schemas import TokenizationResult
import logging

logger = logging.getLogger(__name__)

class NLPService:
    """Service for NLP operations including tokenization"""
    
    def __init__(self):
        # For now, we use basic tokenization without spaCy
        self.nlp = None
        self.basic_separators = {',', ' ', '[', '\n', ']', '(', ')', '{', '}', '.', '!', '?', ';', ':', "\\", "\\ "}
    
    async def tokenize_text(self, text: str, filename: str = "") -> TokenizationResult:
        """
        Tokenize text using basic tokenization
        
        Args:
            text: Text to tokenize
            filename: Original filename (for additional tokens)
        
        Returns:
            TokenizationResult with tokens and metadata
        """
        try:
            tokens = await self._basic_tokenize(text, filename)
            method = "basic"
            
            token_list = list(tokens)
            s_token_list = set(tokens)
            
            return TokenizationResult(
                tokens=s_token_list,
                token_count=len(token_list),
                unique_tokens=len(s_token_list),
                method=method
            )
            
        except Exception as e:
            logger.error(f"Tokenization failed: {e}")
            raise FileProcessingException(f"Tokenization failed: {str(e)}")
    
    async def _basic_tokenize(self, text: str, filename: str = "") -> Set[str]:
        """Basic tokenization (similar to your Dart implementation)"""
        tokens = set()
        
        text = text.lower()
        
        current_token = ""
        for char in text:
            if char in self.basic_separators:
                if current_token and len(current_token) > 1:
                    tokens.add(current_token)
                current_token = ""
            else:
                current_token += char
        
        if current_token and len(current_token) > 1:
            tokens.add(current_token)
        
        tokens = {token for token in tokens if token and len(token) > 1}
        
        if filename:
            filename_tokens = self._extract_filename_tokens(filename)
            tokens.update(filename_tokens)
        
        return tokens
    
    def _extract_filename_tokens(self, filename: str) -> Set[str]:
        """Extract tokens from filename"""
        name_without_ext = filename.split('.')[0] if '.' in filename else filename
        
        tokens = set()
        separators = r'[-_\s\.]+'
        parts = re.split(separators, name_without_ext.lower())
        
        for part in parts:
            if part and len(part) > 1:
                tokens.add(part)
        
        return tokens
    
    async def analyze_text_similarity(self, text1_tokens: List[str], text2_tokens: List[str]) -> float:
        """
        Calculate similarity between two sets of tokens using Jaccard similarity
        
        Args:
            text1_tokens: First set of tokens
            text2_tokens: Second set of tokens
        
        Returns:
            Similarity score between 0 and 1
        """
        set1 = set(text1_tokens)
        set2 = set(text2_tokens)
        
        intersection = len(set1.intersection(set2))
        union = len(set1.union(set2))
        
        return intersection / union if union > 0 else 0.0
    
    async def get_token_frequency(self, tokens: List[str]) -> dict:
        """Get frequency distribution of tokens"""
        return dict(Counter(tokens))

nlp_service = NLPService()

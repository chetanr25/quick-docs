import fitz
import spacy
import nltk
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
import os

def download_nltk_data():
    try:
        # Set NLTK data path to app-specific directory
        nltk_data_dir = "nltk_data"
        if not os.path.exists(nltk_data_dir):
            os.makedirs(nltk_data_dir)
        nltk.data.path.append(nltk_data_dir)
        
        # Download required NLTK data
        nltk.download('punkt', download_dir=nltk_data_dir)
        nltk.download('stopwords', download_dir=nltk_data_dir)
        return True
    except Exception as e:
        print(f"Failed to download NLTK data: {str(e)}")
        return False

# Initialize NLP components
try:
    download_nltk_data()
    nlp = spacy.load('en_core_web_sm')
except Exception as e:
    print(f"Error initializing NLP: {str(e)}")
    nlp = None

def extract_text_from_pdf(pdf_path):
    try:
        doc = fitz.open(pdf_path)
        text = ""
        for page in doc:
            text += page.get_text()
        doc.close()  # Properly close the document
        return {"status": "success", "text": text}
    except Exception as e:
        return {"status": "error", "message": str(e)}

def process_text(text):
    try:
        if nlp is None:
            return {"status": "error", "message": "NLP not initialized"}
            
        doc = nlp(text)
        # Basic NLP processing with error handling
        tokens = []
        for token in doc:
            if not token.is_stop and token.is_alpha:
                tokens.append(token.text.lower())
        
        if not tokens:
            return {"status": "error", "message": "No valid tokens found"}
            
        return {"status": "success", "processed_text": " ".join(tokens)}
    except Exception as e:
        return {"status": "error", "message": str(e)} 
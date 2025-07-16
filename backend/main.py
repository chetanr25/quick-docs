from fastapi import FastAPI, File, UploadFile
import uvicorn
from docx import Document
import PyPDF2
import io

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.post("/extract_text")
async def extract_text(file: UploadFile = File(...)):
    text = ""
    content = await file.read()
    file_obj = io.BytesIO(content)
        
    file_type = file.content_type
    print(file_type)

    if "pdf" in file_type:
        pdf_reader = PyPDF2.PdfReader(file_obj)
        for page in pdf_reader.pages:
            text += page.extract_text()
        
    elif "wordprocessingml" in file_type:
        doc = Document(file_obj)
        for para in doc.paragraphs:
            text += para.text + "\n"
            
    elif "text" in file_type:
        text = content.decode('utf-8')
        
    else:
        return {"error": "Unsupported file type"}
        
    return {"extracted_text": text}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
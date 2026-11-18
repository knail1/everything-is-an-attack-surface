FROM python:3.12-slim
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
      tesseract-ocr fonts-dejavu-core curl \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir "flask>=3.0" "openai>=1.0" "pytesseract>=0.3.10" "pillow>=10.0"
COPY . /app
EXPOSE 8080
CMD ["python", "app.py"]

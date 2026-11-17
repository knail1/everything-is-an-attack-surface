FROM python:3.12-slim
WORKDIR /app
RUN pip install --no-cache-dir "openai>=1.0"
COPY . /app
# Talk to Ollama running on the host:
ENV LLM_BASE_URL=http://host.docker.internal:11434/v1
CMD ["python", "demo.py"]

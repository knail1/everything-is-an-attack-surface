FROM python:3.12-slim
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir "openai>=1.0"
COPY . /app
RUN chmod +x entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]

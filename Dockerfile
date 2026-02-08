FROM python:3.11-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PORT=7860 \
    REQUIRE_API_PASSWORD=true

WORKDIR /app

# ffmpeg + certs (no git, no clone)
RUN apt-get update \
 && apt-get install -y --no-install-recommends ffmpeg ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY . .

# run as non-root
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 7860

CMD ["sh","-c","gunicorn --bind 0.0.0.0:${PORT:-7860} --workers 2 --worker-class aiohttp.worker.GunicornWebWorker --timeout 120 --graceful-timeout 120 app:app"]


# Use a small Python base image
FROM python:3.11-slim

# Ensure no bytecode & output buffering
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Workdir
WORKDIR /app

# Install system deps (optional but useful) & Python deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app
COPY . .

# Expose container port
EXPOSE 5000

# Run via Gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
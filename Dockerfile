# Stage 1: Build dependencies
FROM python:3.10.12-slim-bullseye AS builder

WORKDIR /app

# Install required packages for building dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    python3-dev \
    libgirepository1.0-dev \
    libcairo2-dev \
    libdbus-1-dev \
    gcc \
    libsystemd-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip3 install --upgrade setuptools
RUN pip3 install --no-cache-dir -r requirements.txt -t /app/dependencies

# Stage 2: Create the runtime image
FROM python:3.10.12-slim-bullseye

WORKDIR /app

# Copy only the dependencies from the builder stage
COPY --from=builder /app/dependencies /usr/local/lib/python3.10/site-packages

# Copy application code
COPY ./App /app/App

# Expose the application port
EXPOSE 5000

# Set the default command
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "App.server:app"]

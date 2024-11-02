FROM python:3.10.12-slim-bullseye

WORKDIR /app

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

COPY requirements.txt .

RUN pip3 install --upgrade setuptools

RUN pip3 install --no-cache-dir -r requirements.txt

COPY ./App /app/App

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "App.server:app"]
FROM python:3.11-slim
WORKDIR /code

# Install Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ app/

# Run it
CMD ["python", "app/main.py"]

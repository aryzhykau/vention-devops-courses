# Stage 1 - Build stage
FROM python:3.9-slim as build

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2 - Runtime stage
FROM python:3.9-slim

WORKDIR /app

COPY --from=build /usr/local/lib/python3.9 /usr/local/lib/python3.9
COPY --from=build /usr/local/bin /usr/local/bin
COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]

# app/Dockerfile
# Stage 1: build wheels
FROM python:3.11-slim AS build
WORKDIR /app
COPY requirements.txt .
RUN python -m pip install --upgrade pip \
    && pip wheel --wheel-dir=/wheels -r requirements.txt

# Stage 2: runtime
FROM python:3.11-slim
WORKDIR /app
COPY --from=build /wheels /wheels
COPY requirements.txt .
RUN pip install --no-index --find-links=/wheels -r requirements.txt
COPY app.py .
EXPOSE 8080
CMD ["python", "app.py"]

# Stage 1: builder
FROM python:3.11-slim AS builder
WORKDIR /app
COPY app/requirements.txt .
RUN pip install --upgrade pip && pip wheel -r requirements.txt --wheel-dir /wheels

# Stage 2: runtime
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /wheels /wheels
RUN pip install --no-index --find-links=/wheels -r app/requirements.txt
COPY app /app
ENV PORT=8080
EXPOSE 8080
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:8080", "--workers", "2"]

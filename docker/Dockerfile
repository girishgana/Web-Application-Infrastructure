
# Stage 1: build dependencies
FROM python:3.11-slim AS builder

WORKDIR /app

# Copy requirements.txt
COPY app/requirements.txt .

# Install pip wheels (cached in /wheels)
RUN pip install --upgrade pip && pip wheel -r requirements.txt --wheel-dir /wheels

# Stage 2: runtime image
FROM python:3.11-slim

WORKDIR /app

# Copy wheels from builder
COPY --from=builder /wheels /wheels

# Copy requirements.txt again (so pip can see it here)
COPY app/requirements.txt .

# Install dependencies from wheels
RUN pip install --no-index --find-links=/wheels -r requirements.txt

# Copy app code
COPY app /app

# Expose port
ENV PORT=8080
EXPOSE 8080

# Start Gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:8080", "main:app"]

# Use a Python 3.12 slim image as the base
FROM python:3.12-slim

# Prevent Python from writing .pyc files and enable unbuffered output
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set the environment variables which the app expects
ENV APP_DATABASE_URL="postgresql://dbadmin%40todo-postgres:YourSecurePassword123!@todo-postgres.postgres.database.azure.com:5432/tododb?sslmode=require" \
    OTEL_EXPORTER_OTLP_ENDPOINT="http://otel-lgtm:4318" \
    ENABLE_LOGS_ALL=true \
    OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED=true \
    OTEL_METRICS_EXPORTER=otlp \
    OTEL_TRACES_EXPORTER=otlp

# Set the working directory
WORKDIR /app

# Install system dependencies (if needed) – for example, gcc if any package requires compiling C extensions
# RUN apt-get update && apt-get install -y gcc

# Install Poetry
RUN pip install poetry

# Copy Poetry configuration files first to leverage Docker layer caching
COPY pyproject.toml poetry.lock* /app/

# Install dependencies without creating a virtual environment (so they go into the container's global Python)
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi

# Copy the rest of the application code
COPY . .

# Expose the port on which the app runs (8082 as per your README)
EXPOSE 8082

# Set the entrypoint to run the OpenTelemetry bootstrap and then start the app via gunicorn with instrumentation.
CMD ["sh", "-c", "poetry run opentelemetry-bootstrap -a install && poetry run opentelemetry-instrument gunicorn 'src.app:main()' --bind=0.0.0.0:8082 -c src/gunicorn.conf.py"]
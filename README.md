# Todo App

The todo app is a simple Flask application written in `Python 3.12` that allows
users to create todos via a REST API. See the application code in `src/` to
understand how the application works and how the data model is defined.

## Quick Start

### Run the plain app

To run the app locally, please adhere to the following steps.
The application will serve its API on port 8082.

```bash
# Setup your Python environment and install dependencies
pip install poetry
poetry install

# Set environment variables which the app expects
APP_DATABASE_URL="sqlite:///test.db" # option for local sqlite database
OTEL_EXPORTER_OTLP_ENDPOINT="dummy" # not important if not using OpenTelemetry
OTEL_TRACES_EXPORTER=none # To prevent error logs when not using OpenTelemetry

# Run application locally
poetry run gunicorn "src.app:main()" --bind=0.0.0.0:8082
```

### Run the app with OpenTelemetry

When running the application with the OpenTelemetry exporter, we follow a
similar setup which additionally requires to define the endpoint of a
OpenTelemetry collector. Subsequently, the app is run with the OpenTelemetry
auto-instrumentation.

```bash
pip install poetry
poetry install

# Set environment variables which the app expects
APP_DATABASE_URL="sqlite:///test.db" # option for local sqlite database
OTEL_EXPORTER_OTLP_ENDPOINT="<host>:4317" # here define the OpenTelemetry endpoint

# Run application locally
poetry run opentelemetry-bootstrap -a install
poetry run opentelemetry-instrument gunicorn "src.app:main()" --bind=0.0.0.0:8082 -c src/gunicorn.conf.py
```

## OpenTelemetry Collector

A collector component is required for the app to sent telemetry data to.
We recommend using the existing [grafana/otel-lgtm](https://github.com/grafana/docker-otel-lgtm)
Docker image.

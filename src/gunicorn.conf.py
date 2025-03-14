import os

collector_endpoint = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT")


def post_fork(server, worker):
    pass

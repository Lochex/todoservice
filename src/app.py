import logging
import os
import uuid

from flask import Flask, request, abort, jsonify
from flask_sqlalchemy import SQLAlchemy
from marshmallow import Schema, fields, ValidationError
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.exc import SQLAlchemyError

app = Flask(__name__)
app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv('APP_DATABASE_URL')
db = SQLAlchemy(app)

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

handler = logging.StreamHandler()
handler.setLevel(logging.INFO)
formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
handler.setFormatter(formatter)
logger.addHandler(handler)


class Todo(db.Model):
    __tablename__ = "todos"

    id = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = db.Column(db.String(80), nullable=False)
    description = db.Column(db.String(120), nullable=True)
    depends_on = db.Column(UUID(as_uuid=True), db.ForeignKey("todos.id"), nullable=True)


class TodoSchema(Schema):
    id = fields.UUID(dump_only=True)
    title = fields.Str(required=True)
    description = fields.Str(required=False)
    depends_on = fields.UUID(required=False)

@app.route("/todos", methods=["GET"])
def get_todos():
    try:
        logger.info(f"Fetching all todos")
        todos = Todo.query.all()
        schema = TodoSchema(many=True)
        response = schema.dump(todos)

        return jsonify(response), 200

    except SQLAlchemyError as e:
        logger.error(f"Database error while fetching todos: {e}")
        return jsonify({"error": "Internal server error"}), 500

@app.route("/todos", methods=["POST"])
def create_todo():
    json_data = request.get_json()
    if not json_data:
        return abort(400, description="No input data provided")
    schema = TodoSchema()
    try:
        data = schema.load(json_data)
    except ValidationError as err:
        return abort(422, err.messages)
    todo = Todo(**data)

    try:
        with db.session.begin():
            db.session.add(todo)
            db.session.commit()
        response = schema.dump(todo)
        logger.info(f"Todo created: {response}")
        return response, 201
    except SQLAlchemyError as e:
        logger.error(f"Database error while fetching todo: {e}")
        return jsonify({"error": "Internal server error"}), 500


def main() -> Flask:
    var_exists = os.getenv('APP_DATABASE_URL')
    if not var_exists:
        raise ValueError("Please set the environment variable APP_DATABASE_URL")

    var_exists = os.getenv('OTEL_EXPORTER_OTLP_ENDPOINT')
    if not var_exists:
        raise ValueError("Please set the environment variable OTEL_EXPORTER_OTLP_ENDPOINT")

    logger.info("Starting application")
    with app.app_context():
        db.create_all()
    return app

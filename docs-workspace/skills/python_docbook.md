# Python Documentation Specialist

## Instructions
When the `docbook` agent identifies a Python project (presence of `pyproject.toml`, `requirements.txt`, `setup.py`, or `Pipfile`), use this skill.

### 1. Project Identity
- **Environment Manager**: Poetry (`poetry.lock`), Pipenv (`Pipfile`), or venv (`requirements.txt`).
- **Python Version**: Check `requires-python` in `pyproject.toml` or runtime.txt.
- **Framework Detection**:
    - **Django**: Search for `django` in deps and `manage.py` file.
    - **FastAPI**: Search for `fastapi` and `FastAPI()` instantiation.
    - **Flask**: Search for `flask` and `Flask(__name__)`.
    - **Data/ML**: Look for pandas, numpy, torch, scikit-learn.

### 2. Architecture Detection (Logic-Based)
**CRITICAL**: Python varies wildly. Trace the import graph.
- **Entry Point**:
    - Web: Look for WSGI/ASGI application variables (`app = ...`).
    - CLI: Look for `if __name__ == "__main__":` blocks or Click/Typer decorators.
- **Pattern Analysis**:
    - **Django**: MVT (Model-View-Template). Identify Apps by `apps.py`.
    - **FastAPI/Flask**:
        - *Micro*: Single file or simple package.
        - *Router Pattern*: Usage of `APIRouter` or `Blueprints` to split logic.
        - *Service Pattern*: Logic separated from routes into `services/` or `crud/` modules.

### 3. Implementation Details
- **Configuration**: `settings.py` (Django), Pydantic `BaseSettings`, or `os.environ` usage.
- **Database**:
    - ORM: SQLAlchemy (`DeclarativeBase`), Django ORM (`models.Model`), Tortoise, or raw SQL.
    - Migrations: Alembic (`alembic.ini`) or Django Migrations.
- **Async**: Check for `async def` usage.

### 4. Quality & Tooling
- **Typing**: Usage of `typing` module (List, Optional) or native types (str, int). Check for `mypy.ini`.
- **Linting/Formating**: `black`, `flake8`, `ruff`, `pylint`.
- **Testing**: `pytest` (look for `conftest.py` or `test_*.py`), `unittest`.

## Output Template Additions
**Technical Stack (Python)**:
- **Framework**: [Django/FastAPI/Flask/Script]
- **Package Manager**: [Poetry/Pip/Conda]
- **Asynchronous**: [Yes/No]


FROM python:3.12-slim

ENV \
    # Fixe la version de Poetry
    POETRY_VERSION=2.2.1 \
    # Empêche Poetry de créer un .venv (on installe direct dans le Python du conteneur)
    POETRY_VIRTUALENVS_CREATE=false \
    # Build automatique
    POETRY_NO_INTERACTION=1 \
    # Affiche les logs (print, erreurs)
    PYTHONUNBUFFERED=1 \
    # Ajoute le dossier d'installation de Poetry au PATH pour utiliser la commande 'poetry'
    PATH="/root/.local/bin:$PATH"

# Installation de curl, installation de poetry, nettoyage de curl
RUN apt-get update && apt-get install -y --no-install-recommends curl && \
    curl -sSL https://install.python-poetry.org | python3 - && \
    apt-get purge -y --auto-remove curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml poetry.lock* ./

RUN poetry install --no-root --no-directory

COPY ./src ./src
RUN poetry install
EXPOSE 8000

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
ARG PYTHON_VERSION_ARG
ARG POETRY_VERSION_ARG

FROM python:${PYTHON_VERSION_ARG}-slim as python-base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/app" \
    VENV_PATH="/opt/app/.venv" \
    APP_USER=user

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

FROM python-base as builder-base
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    curl \
    build-essential

ENV POETRY_VERSION=${POETRY_VERSION_ARG}
RUN curl -k -sSL https://install.python-poetry.org | python -

RUN addgroup --system ${APP_USER} && adduser --system --shell /sbin/nologin --ingroup ${APP_USER} ${APP_USER}

WORKDIR $PYSETUP_PATH
RUN chown ${APP_USER}:${APP_USER} ${PYSETUP_PATH}
COPY --chown=${APP_USER} ./poetry.lock ./pyproject.toml ./

USER ${APP_USER}
RUN poetry install --only main

# 'development' stage installs all dev deps and can be used to develop code.
# For example using docker-compose to mount local volume under /app
FROM python-base as development

# Copying poetry and venv into image
COPY --from=builder-base $POETRY_HOME $POETRY_HOME
COPY --from=builder-base $PYSETUP_PATH $PYSETUP

WORKDIR $PYSETUP_PATH
RUN poetry install

WORKDIR /app
COPY . .

FROM development AS lint
RUN black --config ./pyproject.toml --check app tests
RUN isort . --settings-path ./pyproject.toml --recursive --check-only
CMD ["tail", "-f", "/dev/null"]

# 'test' stage runs our unit tests with pytest and
# coverage.  Build will fail if test coverage is under 95%
FROM development AS test
RUN coverage run --rcfile ./pyproject.toml -m pytest ./tests
RUN coverage report --fail-under 95

FROM python-base as production
COPY --from=builder-base $VENV_PATH $VENV_PATH
COPY ./app /app
WORKDIR /app
CMD  python my_app.py
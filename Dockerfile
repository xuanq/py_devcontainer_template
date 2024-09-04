FROM python:3.10 as dev

WORKDIR /workspaces
COPY ./pyproject.toml ./poetry.lock* ./

ENV PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    VIRTUAL_ENV=/venv/dev \
    POETRY_NO_INTERACTION=true \
    POETRY_VIRTUALENVS_IN_PROJECT=false \
    POETRY_VIRTUALENVS_CREATE=false 

RUN pip install poetry \
&& python -m venv ${VIRTUAL_ENV} \
&& . ${VIRTUAL_ENV}/bin/activate \
&& poetry install

FROM dev as builder

ENV VIRTUAL_ENV=/venv/prod
RUN python -m venv ${VIRTUAL_ENV} \
&& . ${VIRTUAL_ENV}/bin/activate \
&& poetry install --no-root --only main

# 生产镜像，采用slim，直接复制builder环节的runtime
FROM python:3.10.14-slim-bookworm as prod

WORKDIR /app

ENV VIRTUAL_ENV=/venv/prod \
    PYTHONPATH=/app

ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

COPY ./app ./app

# fasti api project
# CMD ["uvicorn", "app.main:app","--host", "0.0.0.0", "--port", "8000"]
CMD ["sleep", "infinity"]

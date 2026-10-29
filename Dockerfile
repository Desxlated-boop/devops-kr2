FROM python:3.12-slim

WORKDIR /app

RUN groupadd --system app && useradd --system --gid app --no-create-home app
COPY --chmod=644 requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY --chmod=644 app.py .

USER app
EXPOSE 8004
CMD ["gunicorn", "--bind", "0.0.0.0:8004", "app:app"]

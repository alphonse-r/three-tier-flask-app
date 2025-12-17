FROM python:3.9-alpine

WORKDIR /two-tier-app

# Copier les dépendances Python
COPY requirements.txt .

# Installer gcc et dépendances pour MySQL
RUN apk add --no-cache gcc musl-dev mariadb-connector-c-dev \
    && pip install --no-cache-dir -r requirements.txt

# Copier tout le projet (app.py, templates/, static/)
COPY . .

EXPOSE 5000

CMD ["python", "-u", "app.py"]


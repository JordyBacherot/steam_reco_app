# Utilisation de l'image officielle Bun (runtime performant pour JS/TS)
FROM oven/bun:1

# Installation de curl (utile pour le healthcheck dans docker-compose)
RUN apt-get -y update;

# Définition du dossier de travail dans le conteneur
WORKDIR /app

# Copie des fichiers de dépendances en premier (optimisation du cache Docker)
COPY package.json bun.lock ./

# Installation des dépendances
RUN bun install

# Copie du reste du code source
COPY ./src ./src

# NOTES DE DEMAARAGE :
# La commande de démarrage est définie dans le `docker-compose.yml`.
# En production : CMD ["bun", "run", "start"]
# En développement (avec hot-reload) : CMD ["bun", "run", "dev"]
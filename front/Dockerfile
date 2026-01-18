# Étape 1 : Construction de l'application Flutter Web
FROM debian:bookworm-slim AS build-env

# Installation des dépendances minimales requises pour Flutter (git, curl, zip...)
RUN apt-get update && apt-get install -y \
    curl \
    git \
    wget \
    unzip \
    && apt-get clean

# Clonage du SDK Flutter
ENV FLUTTER_CHANNEL=stable
ENV FLUTTER_VERSION=3.27.1

# On clone la branche stable
RUN git clone -b $FLUTTER_CHANNEL https://github.com/flutter/flutter.git /usr/local/flutter

# On checkout une version précise pour garantir la reproductibilité du build
# Cela évite que le build casse si une nouvelle version stable sort demain avec des changements majeurs.
RUN cd /usr/local/flutter && git checkout $FLUTTER_VERSION

# Configuration du PATH pour accéder à la commande flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Activation des fonctionnalités Web et désactivation des analytics pour la CI/CD
RUN flutter config --no-analytics
RUN flutter config --enable-web

# Copie des fichiers du projet
WORKDIR /app
COPY . .

# Récupération des dépendances
RUN flutter pub get

# Construction de l'application optimisée pour le web
RUN flutter build web --release

# Étape 2 : Serveur Nginx pour distribuer les fichiers statiques
FROM nginx:1.25-alpine

# Copie des fichiers construits depuis l'étape de build vers le dossier public de Nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Exposition du port 80
EXPOSE 80

# Démarrage de Nginx
CMD ["nginx", "-g", "daemon off;"]

# Étape 1 : Construction de l'application Flutter Web (Version Turbo 🚀)
# On utilise une image officielle pré-compilée avec exactement ta version de Flutter
FROM ghcr.io/cirruslabs/flutter:3.27.1 AS build-env

WORKDIR /app

# On désactive les analytics pour gagner un peu de temps
RUN flutter config --no-analytics

# Copie des fichiers du projet
COPY . .

# Récupération des dépendances
RUN flutter pub get

# Construction de l'application optimisée pour le web
RUN flutter build web --release

# Étape 2 : Serveur Nginx pour distribuer les fichiers statiques (Inchangée, elle était parfaite)
FROM nginx:1.25-alpine

# Copie des fichiers construits depuis l'étape de build vers le dossier public de Nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Exposition du port 80
EXPOSE 80

# Démarrage de Nginx
CMD ["nginx", "-g", "daemon off;"]
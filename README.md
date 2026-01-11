# Steam Recommandation API

# Description de l'API

TODO : A compléter

## Membres du Groupe :

- Bacherot Jordy
- Billard Baptiste
- Beer Alexis
- Mick Léa

## Architecture Technique

Ce projet met en œuvre une architecture micro-services avec :

- **API Principale** : [Hono](https://hono.dev/) tournant sur [Bun](https://bun.sh/).
  - ORM : [TypeORM](https://typeorm.io/)
- **Base de Données** : [MariaDB](https://mariadb.org/)
- **API de Recommandation** : [FastAPI](https://fastapi.tiangolo.com/) (Python)
  - POC connecté à l'API Hono, sans véritable algorithme de recommandation pour le moment.
- **Interface Database** : Adminer

## Installation et Démarrage

Le projet est entièrement conteneurisé avec Docker.

### Pré-requis

- Docker installé.

### Démarrage

Pour lancer l'ensemble de la stack (API, BDD, Recommandation) dans le dossier fruits-market-starter-kit :

```bash
docker compose up -d
```

Cette commande va :

1. Démarrer les conteneurs.
2. Initialiser la base de données.
3. Seeder les données initiales (Produits, Pays, etc.) via le script de seed intégré coté API Hono.

## Accès aux Services

- **API Hono** : http://localhost:3000
  - **Health Check** : http://localhost:3000/health
- **Adminer (Gestion BDD)** : http://localhost:8080
- **API Recommandation** : N'est pas accessible depuis l'extérieur du container.

## Notes supplémentaires

### Pour utiliser l'API Hono seul :

Attention :

- Ne fonctionne pas sans DB et FastAPI.
- D'abord lancé la DB et FastAPI puis l'API Hono (notamment pour la seed).

```bash
bun install
bun run dev
```

### .env

Les .env sont directement donné comme l'application reste du test.

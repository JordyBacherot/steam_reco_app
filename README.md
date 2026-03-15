# Steam Recommendation App

## Description

Application de recommandation de jeux Steam utilisant une architecture micro-services conteneurisée.
Le projet permet à un utilisateur d'obtenir des recommandations basées sur sa bibliothèque Steam ou une saisie manuelle, grâce à un algorithme de filtrage collaboratif (ALS).

## Architecture & Dossiers

- **`api/`** (Node.js / Hono) : API Principale.
  - Gère la logique métier, la gestion des requêtes et fait le lien avec la base de données.
  - Agit comme une passerelle (Gateway) vers le service de recommandation.
  - Gère l'authentification des utilisateurs et leurs accès.
  - **Stack** : Bun, Hono, TypeORM, Axios.
- **`api_recommendation/`** (Python / FastAPI) : Service de Recommandation.
  - Micro-service dédié au calcul des recommandations et à la similarité des jeux.
  - Charge les modèles de Machine Learning et expose les résultats api.
  - **Stack** : Python, FastAPI, Numpy, Pandas, Scikit-learn.
- **`front/`** (Flutter) : Interface Utilisateur Web.
  - Application cliente permettant d'interagir avec l'API.
  - TODO : à compléter
  - **Stack** : Flutter (Web), Dockerisé avec Nginx.
- **`db/`** : Configuration Base de Données.
  - Contient la configuration pour l'initialisation de la base MariaDB.
- **`bruno/`** : Collection de Tests API.
  - Contient les requêtes (GET/POST) pour tester les APIs via le client Bruno.
- **`docker-compose.yml`** : Orchestrateur.
  - Définit et relie tous les services (Front, API, Reco, DB, Adminer).

## Membres du Groupe

- Bacherot Jordy
- Billard Baptiste
- Beer Alexis
- Mick Léa

## Installation et Démarrage

### 1. Pré-requis

- **Docker Desktop** installé et lancé.
- **Git** pour cloner le projet.

### 2. Configuration des Variables d'Environnement (.env)

Avant de lancer le projet, vous devez configurer les variables d'environnement.
Copiez les fichiers d'exemple `.env.example` en `.env` dans les dossiers suivants :

| Dossier               | Commande (Bash/PowerShell)                                   | Description                              |
| --------------------- | ------------------------------------------------------------ | ---------------------------------------- |
| `api/`                | `cp api/.env.example api/.env`                               | Config Hono (DB Host, API Key Reco...)   |
| `api_recommendation/` | `cp api_recommendation/.env.example api_recommendation/.env` | Config sécurisée (API Key)               |
| `db/`                 | `cp db/.env.example db/.env`                                 | Identifiants MariaDB (User, Password...) |
| `front/`              | `cp front/.env.example front/.env`                           | Adresse de l'API Hono                    |

> **Note** : Les fichiers `.env.example` sont pré-remplis avec des valeurs par défaut fonctionnant pour l'environnement Docker local, il faut les copier en `.env` et les compléter. Les seuls fichiers à réellement compléter sont `api_recommendation/.env`, il faut renseigner la clé STEAM_API_KEY et `api/.env`, il faut renseigner GROQ_API_KEY.

### 3. Lancement de l'Application

À la racine du projet, lancez la commande suivante pour construire et démarrer tous les conteneurs :

```bash
docker compose up -d --build
```

Attention, si Docker est très long à démarrer, lancer avec :

```bash
$env:BUILDX_NO_DEFAULT_ATTESTATIONS=1 ; docker compose up --build -d
```

_(L'option `--build` assure que les modifications récentes, notamment dans le Front ou l'API, sont bien prises en compte)_

### 4. Accès aux Services

Une fois les conteneurs démarrés (vérifiez avec `docker compose ps`), vous pouvez accéder aux services :

- **🖥️ Frontend** (Interface Web) : [http://localhost:5173](http://localhost:5173)
- **🚀 API Hono** (Backend Principal) : [http://localhost:3000](http://localhost:3000)
  - Health Check : [http://localhost:3000/health](http://localhost:3000/health)
- **🧠 API Recommandation** (Moteur IA) : [http://localhost:8000](http://localhost:8000) (Accessible, mais protégé par API Key)
  - Docs Swagger : [http://localhost:8000/docs](http://localhost:8000/docs)
- **🗄️ Adminer** (Gestion BDD Visuelle) : [http://localhost:8080](http://localhost:8080)
  - **Système** : MySQL / MariaDB
  - **Serveur** : `db`
  - **Utilisateur/Mdp** : Voir `db/.env` (MARIADB_DATABASE=steam_reco_app / MARIADB_USER=steam_reco_app / MARIADB_ROOT_PASSWORD=root_password1234 / MARIADB_PASSWORD=password1234)
  - **Base de données** : `steam_reco_db`

---

## 🛠️ Développement Local (Hybride)

Bien que l'utilisation complète de Docker soit recommandée, vous pouvez lancer les APIs et le front manuellement sur votre machine (avec `bun`, `poetry` et `flutter`) tout en gardant la Base de Données dans Docker.

### 1. Pré-requis

- **Node.js / Bun** (pour l'API Hono)
- **Python 3.10+ & Poetry** (pour l'API Reco)
- **Flutter SDK** (pour le front)
- **Docker** (pour la BDD en arrière-plan)

### 2. Configuration BDD (Docker Uniquement)

Gardez la BDD dans Docker pour éviter d'installer MariaDB localement.

```bash
# Lance uniquement la DB et Adminer
docker compose up -d db adminer
```

### 3. API Hono (Node.js/Bun)

1.  **Arrêter le conteneur Docker** (si lancé) pour libérer le port 3000 :
    ```bash
    docker stop api
    ```
2.  **Configuration .env** :
    Dans `api/.env`, modifiez l'hôte de la base de données :
    ```ini
    DB_HOST=localhost  # Au lieu de 'db'
    ```
3.  **Lancement** :
    ```bash
    cd api
    bun install
    bun run dev
    ```

### 4. API Recommandation (Python/FastAPI)

1.  **Arrêter le conteneur Docker** (si lancé) pour libérer le port 8000 :

    ```bash
    docker stop api_recommendation
    ```

2.  **Pré-requis** :
    - **Python 3.10+ & Poetry** installé.

3.  **Installation & Lancement** :
    ```bash
    cd api_recommendation
    poetry install
    poetry run fastapi run src/main.py
    ```

### 5. Frontend (Flutter Web)

1.  **Arrêter le conteneur Docker** (si lancé) pour libérer le port 5173 :
    ```bash
    docker stop front
    ```
2.  **Pré-requis** :
    - **Flutter SDK** installé.
    - Un navigateur (Chrome ou Edge) pour le rendu.
3.  **Installation & Lancement** :
    ```bash
    cd front
    flutter pub get
    flutter run -d chrome
    ```

> **Note** : Si vous rencontrez des problèmes de CORS en développement local lors des appels API, lancez Flutter avec la commande suivante :
> `flutter run -d chrome --web-browser-flag "--disable-web-security"`

⚠️ **Note** : En mode hybride, assurez-vous que vos variables d'environnement (`.env`) pointent vers `localhost` pour les services qui tournent sur votre machine, et non vers les noms de conteneurs Docker (comme `db` ou `api_recommendation`).

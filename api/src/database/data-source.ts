import "reflect-metadata";
import { DataSource } from "typeorm";
import { User } from "../entities/User";
import { SteamUser } from "../entities/SteamUser";
import { Game } from "../entities/Game";
import { Review } from "../entities/Review";
import { GameUser } from "../entities/GameUser";
import { AIRecommendation } from "../entities/AIRecommendation";
import { ChatbotRecommendation } from "../entities/ChatbotRecommendation";
import { NearGame } from "../entities/NearGame";

/**
 * Configuration principale de la connexion BDD (MySQL) via TypeORM.
 * Exporte l'instance 'AppDataSource' utilisée dans toute l'app.
 */
export const AppDataSource = new DataSource({
  type: "mysql",

  // Connexion via variables d'environnement (.env ou docker-compose)
  // Astuce : Si DB_HOST="db" mais que le script est lancé sur Windows (process.platform === 'win32'),
  // on force "localhost" car on lance l'API localement en dehors de Docker.
  host: process.env.DB_HOST === 'db' && process.platform === 'win32' ? 'localhost' : process.env.DB_HOST!,
  port: parseInt(process.env.DB_PORT!),
  username: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,

  /**
   * synchronize: true -> Modifie auto la BDD pour coller au code.
   * ✅ Pratique en DEV.
   * ⚠️ DANGEREUX en PROD (perte de données possible).
   * La condition assure que c'est false si NODE_ENV n'est pas "development".
   */
  synchronize: true,

  // Affiche les requêtes SQL en dev pour le debug
  logging: true,

  // Liste des entités à charger
  entities: [
    User,
    SteamUser,
    Game,
    Review,
    GameUser,
    AIRecommendation,
    ChatbotRecommendation,
    NearGame
  ],

  migrations: [],
  subscribers: []
});

// Initialise la connexion au démarrage (appelé dans index.ts)
export async function initializeDatabase() {
  try {
    await AppDataSource.initialize();
    console.log("Data Source has been initialized!");
  } catch (error) {
    console.error("Error during Data Source initialization:", error);
    throw error;
  }
}

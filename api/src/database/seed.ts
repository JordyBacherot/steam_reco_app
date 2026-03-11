import "reflect-metadata";
import { AppDataSource } from "./data-source";
import { User } from "../entities/User";
import { Game } from "../entities/Game";
import { SteamUser } from "../entities/SteamUser";
import { GameUser } from "../entities/GameUser";
import { Review } from "../entities/Review";
import * as fs from "fs";
import * as path from "path";
import csv from "csv-parser";

/**
 * Script de pré-remplissage (Seed) de la base de données.
 * Exécutable manuellement (`bun seed`) ou au lancement de l'API.
 */
export const seedDatabase = async () => {
  try {
    // Connexion si nécessaire (cas du script autonome)
    if (!AppDataSource.isInitialized) {
       await AppDataSource.initialize();
    }
    console.log("Database connected. Checking for existing data...");

    // 1. Création User (Si nécessaire)
    const userCount = await AppDataSource.manager.count(User);
    let user: User | null = null;
    
    if (userCount === 0) {
      console.log("Creating default user...");
      user = new User();
      user.username = "testuser";
      user.email = "test@example.com";
      user.password = await Bun.password.hash("password123");
      user.have_steamid = true;
      await AppDataSource.manager.save(user);
      console.log("User created:", user.id_user);

      // 2. Création SteamUser
      const steamUser = new SteamUser();
      steamUser.id_steam = "76561198000000000";
      steamUser.username_steam = "SteamTestUser";
      steamUser.user = user;
      steamUser.id_user = user.id_user;
      await AppDataSource.manager.save(steamUser);
      console.log("SteamUser created");
    } else {
      console.log("Users already exist. Skipping user creation.");
      user = await AppDataSource.manager.findOneBy(User, { username: "testuser" });
    }

    // 3. Création Jeux (Import depuis CSV)
    const gameCount = await AppDataSource.manager.count(Game);
    if (gameCount < 100) {
      console.log("Importing games from games_full.csv...");
      await importGamesFromCSV();
      console.log("Games imported successfully.");
    } else {
      console.log("Games already exist in database. Skipping import.");
    }

    // 4. Création Bibliothèque et Review (Exemple avec des jeux importés)
    if (user) {
      const games = await AppDataSource.manager.find(Game, { take: 2 });
      if (games.length >= 2) {
        const game1 = games[0];
        const game2 = games[1];

        // Bibliothèque (Liaison User <-> Game)
        const libraryEntry = new GameUser();
        libraryEntry.user = user;
        libraryEntry.game = game1;
        libraryEntry.nb_hours = 150.5;
        await AppDataSource.manager.save(libraryEntry);
        console.log("Library entry created for game:", game1.name);

        // Review
        const review = new Review();
        review.user = user;
        review.game = game2;
        review.text = "Masterpiece.";
        review.id_game = game2.id_game;
        review.id_user = user.id_user;
        await AppDataSource.manager.save(review);
        console.log("Review created for game:", game2.name);
      }
    }

    console.log("Seeding complete!");
  } catch (error) {
    console.error("Error during seeding:", error);
    throw error;
  }
};

/**
 * Importe les jeux depuis le fichier CSV par lots pour optimiser les performances.
 */
async function importGamesFromCSV() {
  const csvFilePath = path.resolve(import.meta.dir, "../../data/games_full.csv");
  const BATCH_SIZE = 1000;
  let batch: any[] = [];

  return new Promise<void>((resolve, reject) => {
    const stream = fs.createReadStream(csvFilePath)
      .pipe(csv());

    stream.on("data", async (data) => {
      batch.push({
        id_game: parseInt(data.appid),
        name: data.name,
        description: data.description,
        image_url: data.image_url,
        mean_review: data.mean_review ? parseFloat(data.mean_review) : null,
        studio: data.developer,
      });

      if (batch.length >= BATCH_SIZE) {
        stream.pause(); // Pause le stream pour ne pas saturer la mémoire
        const currentBatch = [...batch];
        batch = [];
        try {
          await AppDataSource.createQueryBuilder()
            .insert()
            .into(Game)
            .values(currentBatch)
            .orIgnore()
            .execute();
        } catch (err) {
          console.error("Batch insert error:", err);
        }
        stream.resume(); // Reprend une fois l'insertion terminée
      }
    });

    stream.on("end", async () => {
      if (batch.length > 0) {
        try {
          await AppDataSource.createQueryBuilder()
            .insert()
            .into(Game)
            .values(batch)
            .orIgnore()
            .execute();
        } catch (err) {
          console.error("Final batch insert error:", err);
        }
      }
      resolve();
    });

    stream.on("error", reject);
  });
}

// Exécution directe si lancé via CLI (`bun run src/database/seed.ts`)
if (import.meta.main) {
    seedDatabase()
        .then(() => process.exit(0))
        .catch(() => process.exit(1));
}

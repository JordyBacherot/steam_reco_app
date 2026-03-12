import "reflect-metadata";
import { AppDataSource } from "./data-source";
import { Game } from "../entities/Game";
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

    // 1. Création Jeux (Import depuis CSV)
    const gameCount = await AppDataSource.manager.count(Game);
    if (gameCount < 100) {
      console.log("Importing games from games_full.csv...");
      await importGamesFromCSV();
      console.log("Games imported successfully.");
    } else {
      console.log("Games already exist in database. Skipping import.");
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
